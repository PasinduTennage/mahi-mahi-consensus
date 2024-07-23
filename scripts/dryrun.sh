# Copyright (c) Mysten Labs, Inc.
# SPDX-License-Identifier: Apache-2.0

# bash run.sh

export RUST_LOG=warn,mysticeti_core::consensus=trace,mysticeti_core::net_sync=warn,mysticeti_core::core=warn

nohup cargo run --bin mysticeti -- dry-run --committee-size 4 --authority 0 > v0.log.ansi &
nohup cargo run --bin mysticeti -- dry-run --committee-size 4 --authority 1 > v1.log.ansi &
nohup cargo run --bin mysticeti -- dry-run --committee-size 4 --authority 2 > v2.log.ansi &
nohup cargo run --bin mysticeti -- dry-run --committee-size 4 --authority 3 > v3.log.ansi &

sleep 5
pkill -f mysticeti
