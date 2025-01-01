// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

use std::{
    collections::{HashMap, VecDeque},
    sync::Arc,
};

use super::{base_committer::BaseCommitter, LeaderStatus, DEFAULT_WAVE_LENGTH};
use crate::{
    block_store::BlockStore,
    committee::Committee,
    consensus::base_committer::BaseCommitterOptions,
    metrics::Metrics,
    types::{format_authority_round, AuthorityIndex, BlockReference, RoundNumber},
};

/// A universal committer uses a collection of committers to commit a sequence of leaders.
/// It can be configured to use a combination of different commit strategies, including
/// multi-leaders, backup leaders, and pipelines.
pub struct UniversalCommitter {
    block_store: BlockStore,
    committers: Vec<BaseCommitter>,
    metrics: Arc<Metrics>,
    previously_committed_leaders: HashMap<(AuthorityIndex, RoundNumber), LeaderStatus>,
    wave_length: u64,
}

impl UniversalCommitter {
    /// Try to commit part of the dag. This function is idempotent and returns a list of
    /// ordered decided leaders.
    #[tracing::instrument(skip_all, fields(last_decided = % last_decided))]
    pub fn try_commit(
        &mut self,
        last_decided: BlockReference,
        threshold_round: RoundNumber,
    ) -> Vec<LeaderStatus> {
        let highest_known_round = self.block_store.highest_round();
        if highest_known_round < self.wave_length {
            return Vec::new();
        }
        let last_decided_round = last_decided.round();
        let last_decided_round_authority = (last_decided.round(), last_decided.authority);

        // Try to decide as many leaders as possible, starting with the highest round.
        let mut leaders = VecDeque::new();
        for round in (last_decided_round..=highest_known_round).rev() {
            if round + self.wave_length > threshold_round {
                continue;
            }
            for committer in self.committers.iter().rev() {
                // Skip committers that don't have a leader for this round.
                let Some(leader) = committer.elect_leader(round) else {
                    continue;
                };

                let mut status = LeaderStatus::Undecided(leader, round);
                let mut found = false;

                match self.previously_committed_leaders.get(&(leader, round)) {
                    Some(LeaderStatus::Commit(block)) => {
                        status = LeaderStatus::Commit(block.clone());
                        tracing::debug!(
                            "Already Committed {}",
                            format_authority_round(leader, round)
                        );
                        found = true;
                    }
                    Some(LeaderStatus::Skip(ai, rn)) => {
                        status = LeaderStatus::Skip(ai.clone(), rn.clone());
                        tracing::debug!(
                            "Already Skipped {}",
                            format_authority_round(leader, round)
                        );
                        found = true;
                    }
                    Some(LeaderStatus::Undecided(ai, rn)) => {
                        found = false;
                    }
                    None => {
                        found = false;
                    }
                }

                if !found {
                    tracing::debug!(
                        "Trying to decide {} with {committer}",
                        format_authority_round(leader, round)
                    );

                    // Try to directly decide the leader.
                    status = committer.try_direct_decide(leader, round);
                    self.update_metrics(&status, true);
                    tracing::debug!("Outcome of direct rule: {status}");

                    // If we can't directly decide the leader, try to indirectly decide it.
                    if !status.is_decided() {
                        status = committer.try_indirect_decide(leader, round, leaders.iter());
                        self.update_metrics(&status, false);
                        tracing::debug!("Outcome of indirect rule: {status}");
                    }

                    // if the status is COMMIT put it in the map
                    if status.is_decided() {
                        self.previously_committed_leaders
                            .insert((leader, round), status.clone());
                    }
                }

                leaders.push_front(status);
            }
        }

        // The decided sequence is the longest prefix of decided leaders.
        leaders
            .into_iter()
            // Skip all leaders before the last decided round.
            .skip_while(|x| (x.round(), x.authority()) != last_decided_round_authority)
            // Skip the last decided leader.
            .skip(1)
            // Filter out all the genesis.
            .filter(|x| x.round() > 0)
            // Stop the sequence upon encountering an undecided leader.
            .take_while(|x| x.is_decided())
            .inspect(|x| tracing::debug!("Decided {x}"))
            .collect()
    }

    /// Return list of leaders for the round. Syncer may give those leaders some extra time.
    /// To preserve (theoretical) liveness, we should wait `Delta` time for at least the first leader.
    /// Can return empty vec if round does not have a designated leader.
    pub fn get_leaders(&self, round: RoundNumber) -> Vec<AuthorityIndex> {
        self.committers
            .iter()
            .filter_map(|committer| committer.elect_leader(round))
            .collect()
    }

    /// Update metrics.
    fn update_metrics(&self, leader: &LeaderStatus, direct_decide: bool) {
        let authority = leader.authority().to_string();
        let direct_or_indirect = if direct_decide { "direct" } else { "indirect" };
        let status = match leader {
            LeaderStatus::Commit(..) => format!("{direct_or_indirect}-commit"),
            LeaderStatus::Skip(..) => format!("{direct_or_indirect}-skip"),
            LeaderStatus::Undecided(..) => return,
        };
        self.metrics
            .committed_leaders_total
            .with_label_values(&[&authority, &status])
            .inc();
    }
}

/// A builder for a universal committer. By default, the builder creates a single base committer,
/// that is, a single leader and no pipeline.
pub struct UniversalCommitterBuilder {
    committee: Arc<Committee>,
    block_store: BlockStore,
    metrics: Arc<Metrics>,
    wave_length: RoundNumber,
    number_of_leaders: usize,
    pipeline: bool,
}

impl UniversalCommitterBuilder {
    pub fn new(committee: Arc<Committee>, block_store: BlockStore, metrics: Arc<Metrics>) -> Self {
        Self {
            committee,
            block_store,
            metrics,
            wave_length: DEFAULT_WAVE_LENGTH,
            number_of_leaders: 1,
            pipeline: false,
        }
    }

    pub fn with_wave_length(mut self, wave_length: RoundNumber) -> Self {
        self.wave_length = wave_length;
        self
    }

    pub fn with_number_of_leaders(mut self, number_of_leaders: usize) -> Self {
        self.number_of_leaders = number_of_leaders;
        self
    }

    pub fn with_pipeline(mut self, pipeline: bool) -> Self {
        self.pipeline = pipeline;
        self
    }

    pub fn build(self) -> UniversalCommitter {
        let mut committers = Vec::new();
        let pipeline_stages = if self.pipeline { self.wave_length } else { 1 };
        for round_offset in 0..pipeline_stages {
            for leader_offset in 0..self.number_of_leaders {
                let options = BaseCommitterOptions {
                    wave_length: self.wave_length,
                    round_offset,
                    leader_offset: leader_offset as RoundNumber,
                    pipelined: self.pipeline,
                };
                let committer =
                    BaseCommitter::new(self.committee.clone(), self.block_store.clone())
                        .with_options(options);
                committers.push(committer);
            }
        }

        UniversalCommitter {
            block_store: self.block_store,
            committers,
            metrics: self.metrics,
            previously_committed_leaders: HashMap::new(),
            wave_length: self.wave_length,
        }
    }
}
