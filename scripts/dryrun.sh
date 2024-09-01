# Copyright (c) Mysten Labs, Inc.
# SPDX-License-Identifier: Apache-2.0

# bash run.sh
output_dir=logs/local/
mkdir -p ${output_dir}

pkill -f mysticeti

cargo build

export RUST_LOG=warn,mysticeti_core::consensus=debug,mysticeti_core::net_sync=warn,mysticeti_core::core=debug


nohup ./target/debug/mysticeti  dry-run --committee-size 4 --authority 0 > ${output_dir}v0.log.ansi &
nohup ./target/debug/mysticeti  dry-run --committee-size 4 --authority 1 > ${output_dir}v1.log.ansi &
nohup ./target/debug/mysticeti  dry-run --committee-size 4 --authority 2 > ${output_dir}v2.log.ansi &
nohup ./target/debug/mysticeti  dry-run --committee-size 4 --authority 3 > ${output_dir}v3.log.ansi &

sleep 130

python3 scripts/block-create-test.py   ${output_dir}v0.log.ansi ${output_dir}v1.log.ansi ${output_dir}v2.log.ansi ${output_dir}v3.log.ansi
python3 scripts/commit-test.py         ${output_dir}v0.log.ansi ${output_dir}v1.log.ansi ${output_dir}v2.log.ansi ${output_dir}v3.log.ansi
python3 scripts/simple-commit-count.py ${output_dir}v0.log.ansi ${output_dir}v1.log.ansi ${output_dir}v2.log.ansi ${output_dir}v3.log.ansi

output_file=${output_dir}stats.log

python3 experiments/python/client-stats.py client-times-0.txt 5 0 >> ${output_file}
python3 experiments/python/client-stats.py client-times-1.txt 5 1 >> ${output_file}
python3 experiments/python/client-stats.py client-times-2.txt 5 2 >> ${output_file}
python3 experiments/python/client-stats.py client-times-3.txt 5 3 >> ${output_file}
