cargo run --bin mysticeti -- benchmark-genesis --ips 127.0.0.1 127.0.0.1 127.0.0.1 127.0.0.1 --working-directory /home/tennage/Documents/asyncmysticeti/assets/ --node-parameters-path /home/tennage/Documents/asyncmysticeti/scripts/node-parameters.yml

export RUST_LOG=warn,mysticeti_core::consensus=debug,mysticeti_core::net_sync=warn,mysticeti_core::core=debug

nohup cargo run --bin mysticeti -- run --authority 0 --committee-path /home/tennage/Documents/asyncmysticeti/assets/committee.yaml --public-config-path /home/tennage/Documents/asyncmysticeti/assets/public-config.yaml --private-config-path /home/tennage/Documents/asyncmysticeti/assets/private-config-0.yaml --client-parameters-path /home/tennage/Documents/asyncmysticeti/scripts/client-parameters.yml >v0.log.ansi &
nohup cargo run --bin mysticeti -- run --authority 1 --committee-path /home/tennage/Documents/asyncmysticeti/assets/committee.yaml --public-config-path /home/tennage/Documents/asyncmysticeti/assets/public-config.yaml --private-config-path /home/tennage/Documents/asyncmysticeti/assets/private-config-1.yaml --client-parameters-path /home/tennage/Documents/asyncmysticeti/scripts/client-parameters.yml >v1.log.ansi &
nohup cargo run --bin mysticeti -- run --authority 2 --committee-path /home/tennage/Documents/asyncmysticeti/assets/committee.yaml --public-config-path /home/tennage/Documents/asyncmysticeti/assets/public-config.yaml --private-config-path /home/tennage/Documents/asyncmysticeti/assets/private-config-2.yaml --client-parameters-path /home/tennage/Documents/asyncmysticeti/scripts/client-parameters.yml >v2.log.ansi &
nohup cargo run --bin mysticeti -- run --authority 3 --committee-path /home/tennage/Documents/asyncmysticeti/assets/committee.yaml --public-config-path /home/tennage/Documents/asyncmysticeti/assets/public-config.yaml --private-config-path /home/tennage/Documents/asyncmysticeti/assets/private-config-3.yaml --client-parameters-path /home/tennage/Documents/asyncmysticeti/scripts/client-parameters.yml >v3.log.ansi &

sleep 60



pkill -f mysticeti

sleep 5

python3 scripts/block-create-test.py v0.log.ansi v1.log.ansi v2.log.ansi v3.log.ansi
python3 scripts/commit-test.py v0.log.ansi v1.log.ansi v2.log.ansi v3.log.ansi
python3 scripts/simple-commit-count.py v0.log.ansi v1.log.ansi v2.log.ansi v3.log.ansi