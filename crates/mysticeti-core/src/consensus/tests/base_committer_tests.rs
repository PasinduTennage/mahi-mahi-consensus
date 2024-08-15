// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

use crate::{
    config::node_defaults::default_wave_length, consensus::{
        universal_committer::UniversalCommitterBuilder,
        LeaderStatus,
        DEFAULT_WAVE_LENGTH,
    }, test_util::{build_dag, build_dag_layer, committee, test_metrics, TestBlockWriter}, types::BlockReference
};

/// Commit one leader. Done
#[test]
#[tracing_test::traced_test]
fn direct_commit() {
    let committee = committee(4); // create committee of size 4.

    let mut block_writer = TestBlockWriter::new(&committee); // define block writer with committee
    let references = build_dag(&committee, &mut block_writer, None, DEFAULT_WAVE_LENGTH*2+1);
    tracing::trace!("References: {:?}", references);
    // for i in 0..references.len() {
    //     tracing::trace!("i={}, a[i]={:?}, r[i]={:?}, d[i]={:?}", i, references[i].authority, references[i].round, references[i].digest);
    // }
    //println!("References: {:?}", references);
    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .build(); // create a committer 
    let last_committed = BlockReference::new_test(0, 0); // nothing in the last committed history.
    let threshold_round = DEFAULT_WAVE_LENGTH*2;
    let sequence = committer.try_commit(last_committed, threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");

    assert_eq!(sequence.len(), 1);
    if let LeaderStatus::Commit(ref block) = sequence[0] {
        assert_eq!(block.author(), committee.elect_leader(DEFAULT_WAVE_LENGTH))
    } else {
        panic!("Expected a committed leader")
    };
} // change to make test DAG longer

/// Ensure idempotent applies. DONE
#[test]
#[tracing_test::traced_test]
fn idempotence() {
    let committee = committee(4);

    let mut block_writer = TestBlockWriter::new(&committee);
    build_dag(&committee, &mut block_writer, None, DEFAULT_WAVE_LENGTH*2+1);

    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .build();

    // Commit one block.
    let last_committed = BlockReference::new_test(0, 0);
    let threshold_round = DEFAULT_WAVE_LENGTH*2;
    let committed = committer.try_commit(last_committed,threshold_round);

    // Ensure we don't commit it again.
    let max = committed.into_iter().max().unwrap();
    let last_committed = BlockReference::new_test(max.authority(), max.round());
    let sequence = committer.try_commit(last_committed, threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");
    assert!(sequence.is_empty());
}

/// Commit one by one each leader as the dag progresses in ideal conditions. DONE
#[test]
#[tracing_test::traced_test]
fn multiple_direct_commit() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let mut last_committed = BlockReference::new_test(0, 0);
    for n in 1..=wave_length{ //shorten to test
        // println!("n: {:?}", n);
        let enough_blocks = wave_length * (n + 1) - 1 ; // 11, 12, 13,...
        let mut block_writer = TestBlockWriter::new(&committee);
        build_dag(&committee, &mut block_writer, None, enough_blocks);
        let mut committer = UniversalCommitterBuilder::new(
            committee.clone(),
            block_writer.into_block_store(),
            test_metrics(),
        )
        .with_wave_length(wave_length)
        .build();
        // let mut counter = 0;
        // // if n % 5 == 0 {
        // //     counter += wave_length;
        // // }
        let threshold_round = enough_blocks+1;
        let sequence: Vec<LeaderStatus> = committer.try_commit(last_committed,threshold_round);
        tracing::info!("Commit sequence: {sequence:?}");
        assert_eq!(sequence.len(), 1);

        let leader_round = n *wave_length; // leader round value will automatically calculate to wave.
        // println!("leader_round value: {:?}", leader_round);
        // println!("leader_round: {:?}", committee.elect_leader(leader_round));

        if let LeaderStatus::Commit(ref block) = sequence[0] {
            assert_eq!(block.author(), committee.elect_leader(leader_round));
        } else {
            panic!("Expected a committed leader")
        }

        let last = sequence.into_iter().last().unwrap();
        last_committed = BlockReference::new_test(last.authority(), last.round());
    }
}

/// Commit 10 leaders in a row (calling the committer after adding them). DONE
#[test]
#[tracing_test::traced_test]
fn direct_commit_late_call() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let n: u64 = wave_length*2;
    let enough_blocks = wave_length * n+wave_length;
    let mut block_writer = TestBlockWriter::new(&committee);
    build_dag(&committee, &mut block_writer, None, enough_blocks);

    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .with_wave_length(wave_length)
    .build();

    let last_committed = BlockReference::new_test(0, 0);
    let threshold_round = enough_blocks+1;
    let sequence = committer.try_commit(last_committed,threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");

    assert_eq!(sequence.len(), n as usize);
    for (i, leader_block) in sequence.iter().enumerate() {
        let leader_round = (i as u64 + 1) * wave_length;
        if let LeaderStatus::Commit(ref block) = leader_block {
            assert_eq!(block.author(), committee.elect_leader(leader_round));
        } else {
            panic!("Expected a committed leader")
        };
    }
}

/// Do not commit anything if we are still in the first wave. DONE
#[test]
#[tracing_test::traced_test]
fn no_genesis_commit() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let first_commit_round = wave_length;
    for r in 0..first_commit_round {
        let mut block_writer = TestBlockWriter::new(&committee);
        build_dag(&committee, &mut block_writer, None, r);

        let mut committer = UniversalCommitterBuilder::new(
            committee.clone(),
            block_writer.into_block_store(),
            test_metrics(),
        )
        .with_wave_length(wave_length)
        .build();

        let threshold_value = wave_length;
        let last_committed = BlockReference::new_test(0, 0);
        let sequence = committer.try_commit(last_committed,threshold_value);
        tracing::info!("Commit sequence: {sequence:?}");
        assert!(sequence.is_empty());
    }
}

/// We directly skip the leader if it is missing. DONE
#[test]
#[tracing_test::traced_test]
fn no_leader() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let mut block_writer = TestBlockWriter::new(&committee);

    // Add enough blocks to finish wave 0.
    let decision_round_0 = wave_length;
    let references = build_dag(&committee, &mut block_writer, None, decision_round_0);

    // Add enough blocks to reach the decision round of the first leader (but without the leader).
    let leader_round_1 = wave_length;
    let leader_1 = committee.elect_leader(leader_round_1);
    
    let references_without_leader_1: Vec<_> = references
        .into_iter()
        .filter(|x| x.authority != leader_1)
        .collect();

    // Filter out the leader
    // let connections = committee
    //     .authorities()
    //     .filter(|&authority| authority != leader_1)
    //     .map(|authority| (authority, references_without_leader_1.clone()));
    // let references: Vec<BlockReference> = build_dag_layer(connections.collect(), &mut block_writer);
    // come to decision round of leader 1
    let decision_round_1 = 2 * wave_length;
    build_dag(
        &committee,
        &mut block_writer,
        Some(references_without_leader_1),
        decision_round_1,
    );

    // Ensure no blocks are committed.
    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .with_wave_length(wave_length)
    .build();

    let threshold_round = decision_round_1+1;
    let last_committed = BlockReference::new_test(0, 0);
    let sequence = committer.try_commit(last_committed,threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");

    assert_eq!(sequence.len(), 1);
    if let LeaderStatus::Skip(leader, round) = sequence[0] {
        assert_eq!(leader, leader_1);
        assert_eq!(round, leader_round_1);
    } else {
        panic!("Expected to directly skip the leader");
    }
}

/// We directly skip the leader if it has enough blame. DONE
#[test]
#[tracing_test::traced_test]
fn direct_skip() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let mut block_writer = TestBlockWriter::new(&committee);

    // Add enough blocks to reach the first leader.
    let leader_round_1 = wave_length;
    let references_1 = build_dag(&committee, &mut block_writer, None, leader_round_1);

    // Filter out that leader.
    let references_without_leader_1: Vec<_> = references_1
        .into_iter()
        .filter(|x| x.authority != committee.elect_leader(leader_round_1))
        .collect();

    // Add enough blocks to reach the decision round of the first leader.
    let decision_round_1 = 2 * wave_length;
    build_dag(
        &committee,
        &mut block_writer,
        Some(references_without_leader_1),
        decision_round_1,
    );

    // Ensure the leader is skipped.
    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .with_wave_length(wave_length)
    .build();

    let threshold_round = decision_round_1+1;
    let last_committed = BlockReference::new_test(0, 0);
    let sequence = committer.try_commit(last_committed,threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");

    assert_eq!(sequence.len(), 1);
    if let LeaderStatus::Skip(leader, round) = sequence[0] {
        assert_eq!(leader, committee.elect_leader(leader_round_1));
        assert_eq!(round, leader_round_1);
    } else {
        panic!("Expected to directly skip the leader");
    }
}

/// Indirect-commit the first leader. DONE
#[test]
#[tracing_test::traced_test]
fn indirect_commit() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let mut block_writer = TestBlockWriter::new(&committee);

    // Add enough blocks to reach the 1st leader.
    let leader_round_1 = wave_length;
    let references_1 = build_dag(&committee, &mut block_writer, None, leader_round_1);

    // Filter out that leader.
    let references_without_leader_1: Vec<_> = references_1
        .iter()
        .cloned()
        .filter(|x| x.authority != committee.elect_leader(leader_round_1))
        .collect();

    // Only 2f+1 validators vote for the 1st leader.
    let connections_with_leader_1 = committee
        .authorities()
        .take(committee.quorum_threshold() as usize)
        .map(|authority| (authority, references_1.clone()))
        .collect();
    let references_with_votes_for_leader_1 =
        build_dag_layer(connections_with_leader_1, &mut block_writer);

    let connections_without_leader_1 = committee
        .authorities()
        .skip(committee.quorum_threshold() as usize)
        .map(|authority| (authority, references_without_leader_1.clone()))
        .collect();
    let references_without_votes_for_leader_1 =
        build_dag_layer(connections_without_leader_1, &mut block_writer);

    // Only f+1 validators certify the 1st leader.
    let mut references_3 = Vec::new();

    let connections_with_votes_for_leader_1 = committee
        .authorities()
        .take(committee.validity_threshold() as usize)
        .map(|authority| (authority, references_with_votes_for_leader_1.clone()))
        .collect();
    references_3.extend(build_dag_layer(
        connections_with_votes_for_leader_1,
        &mut block_writer,
    ));

    let references: Vec<_> = references_without_votes_for_leader_1
        .into_iter()
        .chain(references_with_votes_for_leader_1.into_iter())
        .take(committee.quorum_threshold() as usize)
        .collect();
    let connections_without_votes_for_leader_1 = committee
        .authorities()
        .skip(committee.validity_threshold() as usize)
        .map(|authority| (authority, references.clone()))
        .collect();
    references_3.extend(build_dag_layer(
        connections_without_votes_for_leader_1,
        &mut block_writer,
    ));

    // Add enough blocks to decide the 2nd leader.
    let decision_round_3 = 3 * wave_length ;
    build_dag(
        &committee,
        &mut block_writer,
        Some(references_3),
        decision_round_3,
    );

    // Ensure we commit the 1st leader.
    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .with_wave_length(wave_length)
    .build();
    let threshold_round = decision_round_3+1;
    let last_committed = BlockReference::new_test(0, 0);
    let sequence = committer.try_commit(last_committed,threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");
    assert_eq!(sequence.len(), 2);

    let leader_round = wave_length;
    let leader = committee.elect_leader(leader_round);
    if let LeaderStatus::Commit(ref block) = sequence[0] {
        assert_eq!(block.author(), leader);
    } else {
        panic!("Expected a committed leader")
    };
}

/// Check that booster round works where the 2nd leader only receives f+1 connections. DONE
#[test]
#[tracing_test::traced_test]
fn commit_with_booster() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let mut block_writer = TestBlockWriter::new(&committee);

    // Add enough blocks to reach the 2nd leader.
    let leader_round_2 = 2 * wave_length;
    let references_2 = build_dag(&committee, &mut block_writer, None, leader_round_2);

    // Filter out that leader.
    let leader_2 = committee.elect_leader(leader_round_2);
    let references_without_leader_2: Vec<_> = references_2
        .iter()
        .cloned()
        .filter(|x| x.authority != leader_2)
        .collect();

    // Only f+1 validators connect to the 2nd leader.
    let mut references = Vec::new();

    let connections_with_leader_2 = committee
        .authorities()
        .take(committee.validity_threshold() as usize)
        .map(|authority| (authority, references_2.clone()))
        .collect();
    references.extend(build_dag_layer(
        connections_with_leader_2,
        &mut block_writer,
    ));

    let connections_without_leader_2 = committee
        .authorities()
        .skip(committee.validity_threshold() as usize)
        .map(|authority| (authority, references_without_leader_2.clone()))
        .collect();
    references.extend(build_dag_layer(
        connections_without_leader_2,
        &mut block_writer,
    ));

    // Add enough blocks to reach the decision round of the 3rd leader.
    let decision_round_3 = 4 * wave_length+1;
    build_dag(
        &committee,
        &mut block_writer,
        Some(references),
        decision_round_3,
    );

    // Ensure we commit the leaders of wave 1 and 3
    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .with_wave_length(wave_length)
    .build();

    let threshold_round = decision_round_3;
    let last_committed = BlockReference::new_test(0, 0);
    let sequence = committer.try_commit(last_committed,threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");
    // println!("sequence length: {:?}", sequence.len());
    assert_eq!(sequence.len(), 3);

    // Ensure we commit the 1st leader.
    let leader_round_1 = wave_length;
    let leader_1 = committee.elect_leader(leader_round_1);
    if let LeaderStatus::Commit(ref block) = sequence[0] {
        assert_eq!(block.author(), leader_1);
    } else {
        panic!("Expected a committed leader")
    };

    // Ensure we commit the 2nd leader.
    if let LeaderStatus::Commit(ref block) = sequence[1] {
        assert_eq!(block.author(), leader_2);
    } else {
        panic!("Expected a committed leader")
    }

    // Ensure we commit the 3rd leader.
    let leader_round_3 = 3 * wave_length;
    let leader_3 = committee.elect_leader(leader_round_3);
    if let LeaderStatus::Commit(ref block) = sequence[2] {
        assert_eq!(block.author(), leader_3);
    } else {
        panic!("Expected a committed leader")
    }
}

/// The booster round ensure we may commit even with a single link to the leader. DONE
#[test]
#[tracing_test::traced_test]
fn commit_single_link_leader_with_booster() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let mut block_writer = TestBlockWriter::new(&committee);

    // Add enough blocks to reach the first leader.
    let leader_round_1 = wave_length;
    let references_1 = build_dag(&committee, &mut block_writer, None, leader_round_1);

    // Filter out that leader.
    let references_without_leader_1: Vec<_> = references_1
        .iter()
        .cloned()
        .filter(|x| x.authority != committee.elect_leader(leader_round_1))
        .collect();

    // Create a dag layer where only one authority votes for the first leader.
    let mut authorities = committee.authorities();
    let leader_connection = vec![(authorities.next().unwrap(), references_1)];
    let non_leader_connections: Vec<_> = authorities
        .take((committee.validity_threshold()) as usize)
        .map(|authority| (authority, references_without_leader_1.clone()))
        .collect();

    let connections: std::iter::Chain<std::vec::IntoIter<(u64, Vec<BlockReference>)>, std::vec::IntoIter<(u64, Vec<BlockReference>)>> = leader_connection.into_iter().chain(non_leader_connections);
    let references = build_dag_layer(connections.collect(), &mut block_writer);

    // Add enough blocks to reach the decision round of the first leader.
    let decision_round_1 = wave_length;
    build_dag(
        &committee,
        &mut block_writer,
        Some(references),
        decision_round_1,
    );

    // Ensure no blocks are committed.
    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .with_wave_length(wave_length)
    .build();

    let threshold_round=wave_length;
    let last_committed = BlockReference::new_test(0, 0);
    let sequence = committer.try_commit(last_committed,threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");
    assert!(sequence.is_empty());
}

/// If there is no leader with enough support nor blame, we commit nothing. DONE
#[test]
#[tracing_test::traced_test]
fn undecided() {
    let committee = committee(4);
    let wave_length = DEFAULT_WAVE_LENGTH;

    let mut block_writer = TestBlockWriter::new(&committee);

    // Add enough blocks to reach the first leader.
    let leader_round_1 = wave_length;
    let references_1 = build_dag(&committee, &mut block_writer, None, leader_round_1);

    // Filter out that leader.
    let references_without_leader_1: Vec<_> = references_1
        .iter()
        .cloned()
        .filter(|x| x.authority != committee.elect_leader(leader_round_1))
        .collect();

    // Create a dag layer where only one authority votes for the first leader.
    let mut authorities = committee.authorities();
    let leader_connection = vec![(authorities.next().unwrap(), references_1)];
    let non_leader_connections: Vec<_> = authorities
        .take(1 as usize)
        .map(|authority| (authority, references_without_leader_1.clone()))
        .collect();

    let connections = leader_connection.into_iter().chain(non_leader_connections);
    let references = build_dag_layer(connections.collect(), &mut block_writer);

    // Add enough blocks to reach the decision round of the first leader.
    let decision_round_1 = wave_length;
    build_dag(
        &committee,
        &mut block_writer,
        Some(references),
        decision_round_1,
    );

    // Ensure no blocks are committed.
    let mut committer = UniversalCommitterBuilder::new(
        committee.clone(),
        block_writer.into_block_store(),
        test_metrics(),
    )
    .with_wave_length(wave_length)
    .build();
    let threshold_round=decision_round_1+1;

    let last_committed = BlockReference::new_test(0, 0);
    let sequence = committer.try_commit(last_committed,threshold_round);
    tracing::info!("Commit sequence: {sequence:?}");
    assert!(sequence.is_empty());
}
