# Copyright (c) Mysten Labs, Inc.
# SPDX-License-Identifier: Apache-2.0

# bash run.sh

cargo build

export RUST_LOG=warn,mysticeti_core::consensus=debug,mysticeti_core::net_sync=warn,mysticeti_core::core=debug

nohup cargo run --bin mysticeti -- dry-run --committee-size 4 --authority 0 > v0.log.ansi &
nohup cargo run --bin mysticeti -- dry-run --committee-size 4 --authority 1 > v1.log.ansi &
nohup cargo run --bin mysticeti -- dry-run --committee-size 4 --authority 2 > v2.log.ansi &
nohup cargo run --bin mysticeti -- dry-run --committee-size 4 --authority 3 > v3.log.ansi &

sleep 5
pkill -f mysticeti

sleep 5

python3 scripts/block-create-test.py v0.log.ansi v1.log.ansi v2.log.ansi v3.log.ansi
python3 scripts/commit-test.py v0.log.ansi v1.log.ansi v2.log.ansi v3.log.ansi
