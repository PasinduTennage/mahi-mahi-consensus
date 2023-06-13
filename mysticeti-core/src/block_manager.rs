// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

use crate::block_store::BlockStore;
use crate::data::Data;
use crate::types::{BlockReference, StatementBlock};
use std::collections::{HashMap, HashSet, VecDeque};

/// Block manager suspends incoming blocks until they are connected to the existing graph,
/// returning newly connected blocks
#[derive(Default)]
pub struct BlockManager {
    blocks_pending: HashMap<BlockReference, Data<StatementBlock>>,
    block_references_waiting: HashMap<BlockReference, HashSet<BlockReference>>,
    block_store: BlockStore,
}

impl BlockManager {
    #[allow(dead_code)]
    pub fn add_blocks(&mut self, blocks: Vec<Data<StatementBlock>>) -> Vec<Data<StatementBlock>> {
        let mut blocks: VecDeque<Data<StatementBlock>> = blocks.into();
        let mut newly_blocks_processed: Vec<Data<StatementBlock>> = vec![];
        while let Some(block) = blocks.pop_front() {
            // Update the highest known round number.

            // check whether we have already processed this block and skip it if so.
            let block_reference = block.reference();
            if self.block_store.block_exists(*block_reference)
                || self.blocks_pending.contains_key(block_reference)
            {
                continue;
            }

            let mut processed = true;
            for included_reference in block.includes() {
                // If we are missing a reference then we insert into pending and update the waiting index
                if !self.block_store.block_exists(*included_reference) {
                    processed = false;
                    self.block_references_waiting
                        .entry(*included_reference)
                        .or_default()
                        .insert(*block_reference);
                }
            }
            if !processed {
                self.blocks_pending.insert(*block_reference, block);
            } else {
                let block_reference = *block_reference;

                // Block can be processed. So need to update indexes etc
                newly_blocks_processed.push(block.clone());
                self.block_store.insert_block(block);

                // Now unlock any pending blocks, and process them if ready.
                if let Some(waiting_references) =
                    self.block_references_waiting.remove(&block_reference)
                {
                    // For each reference see if its unblocked.
                    for waiting_block_reference in waiting_references {
                        let block_pointer = self.blocks_pending.get(&waiting_block_reference).expect("Safe since we ensure the block waiting reference has a valid primary key.");

                        if block_pointer
                            .includes()
                            .iter()
                            .all(|item_ref| !self.block_references_waiting.contains_key(item_ref))
                        {
                            // No dependencies are left unprocessed, so remove from unprocessed list, and add to the
                            // blocks we are processing now.
                            let block = self.blocks_pending.remove(&waiting_block_reference).expect("Safe since we ensure the block waiting reference has a valid primary key.");
                            blocks.push_front(block);
                        }
                    }
                }
            }
        }

        newly_blocks_processed
    }

    pub fn add_own_block(&mut self, block: StatementBlock) -> Data<StatementBlock> {
        // Update the highest known round number.
        let block = Data::new(block);
        self.block_store.insert_block(block.clone());
        block
    }

    pub fn block_store(&self) -> &BlockStore {
        &self.block_store
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::Dag;
    use rand::prelude::StdRng;
    use rand::SeedableRng;

    #[test]
    fn test_block_manager_add_block() {
        let dag =
            Dag::draw("A1:[A0, B0]; B1:[A0, B0]; B2:[A0, B1]; A2:[A1, B2]").add_genesis_blocks();
        assert_eq!(dag.len(), 6); // 4 blocks in dag + 2 genesis
        for seed in 0..100u8 {
            println!("Seed {seed}");
            let iter = dag.random_iter(&mut rng(seed));
            let mut bm = BlockManager::default();
            let mut processed_blocks = HashSet::new();
            for block in iter {
                let processed = bm.add_blocks(vec![block.clone()]);
                print!("Adding {:?}:", block.reference());
                for p in processed {
                    print!("{:?},", p.reference());
                    if !processed_blocks.insert(p.reference().clone()) {
                        panic!("Block {:?} processed twice", p.reference());
                    }
                }
                println!();
            }
            assert_eq!(bm.block_references_waiting.len(), 0);
            assert_eq!(bm.blocks_pending.len(), 0);
            assert_eq!(processed_blocks.len(), dag.len());
            assert_eq!(bm.block_store.len_expensive(), dag.len());
            println!("======");
        }
    }

    fn rng(s: u8) -> StdRng {
        let mut seed = [0; 32];
        seed[0] = s;
        StdRng::from_seed(seed)
    }
}
