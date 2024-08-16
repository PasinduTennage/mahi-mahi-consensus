wave_length=$1
number_of_leaders=$2
enable_pipelining=$3
consensus_only=$4
enable_synchronizer=$5
initial_delay_secs=$6
load=$7
transaction_size=$8

pwd=$(pwd)
. "${pwd}"/experiments/ip.sh

scp -i ${cert} scripts/node-parameters.yml   "${replicas[${index}]}":${remote_home_path}
    scp -i ${cert} scripts/client-parameters.yml "${replicas[${index}]}":${remote_home_path}
    sshpass ssh "${replicas[${index}]}" -i ${cert} "./a_mysticeti/mysticeti benchmark-genesis --ips ${replica1_name} ${replica2_name} ${replica3_name} ${replica4_name} ${replica5_name} ${replica6_name} ${replica7_name} ${replica8_name} ${replica9_name} ${replica10_name} --working-directory ${remote_home_path} --node-parameters-path ${remote_home_path}node-parameters.yml"

rm nohup.out

replica_path="/baxos/replica"
ctl_path="/baxos/client"
config="/home/${username}/baxos/remote-configuration.yml"
output_path="/home/${username}/baxos/logs/"

local_output_path="logs/"

rm -r "${local_output_path}"; mkdir -p "${local_output_path}"

for index in "${!replicas[@]}";
do
  sshpass ssh "${replicas[${index}]}"  -i ${cert}  "pkill replica; pkill client; rm -r ${output_path}; mkdir -p ${output_path}"
done

sleep 10

echo "Killed previously running instances"

echo "starting replicas"

nohup ssh ${replica1}  -i ${cert}   "pkill replica; ./${replica_path} --name 1  --debugLevel 100 --roundTripTime "${roundTripTime}"  --logFilePath ${output_path} --config ${config}" > ${local_output_path}1.log &
nohup ssh ${replica2}  -i ${cert}   "pkill replica; ./${replica_path} --name 2  --debugLevel 100 --roundTripTime "${roundTripTime}"  --logFilePath ${output_path} --config ${config}" > ${local_output_path}2.log &
nohup ssh ${replica3}  -i ${cert}   "pkill replica; ./${replica_path} --name 3  --debugLevel 100 --roundTripTime "${roundTripTime}"  --logFilePath ${output_path} --config ${config}" > ${local_output_path}3.log &
nohup ssh ${replica4}  -i ${cert}   "pkill replica; ./${replica_path} --name 4  --debugLevel 100 --roundTripTime "${roundTripTime}"  --logFilePath ${output_path} --config ${config}" > ${local_output_path}4.log &
nohup ssh ${replica5}  -i ${cert}   "pkill replica; ./${replica_path} --name 5  --debugLevel 100 --roundTripTime "${roundTripTime}"  --logFilePath ${output_path} --config ${config}" > ${local_output_path}5.log &

echo "Started replicas"

sleep 15

nohup ssh ${replica6} -i ${cert}   "pkill client; ./${ctl_path} --name 51 --logFilePath ${output_path} --requestType status --operationType 1  --debugOn --debugLevel 100  --config ${config}" >${local_output_path}status1.log &

echo "Sent initial status to bootstrap"

sleep 20

echo "Starting client[s]"

nohup ssh ${replica6}   -i ${cert}   "pkill client; ./${ctl_path} --name 51 --logFilePath ${output_path} --requestType request --debugOn --debugLevel 100 --arrivalRate "${arrivalRate}" --config ${config}"  >${local_output_path}51.log &
nohup ssh ${replica7}   -i ${cert}   "pkill client; ./${ctl_path} --name 52 --logFilePath ${output_path} --requestType request --debugOn --debugLevel 100 --arrivalRate "${arrivalRate}" --config ${config}"  >${local_output_path}52.log &
nohup ssh ${replica8}   -i ${cert}   "pkill client; ./${ctl_path} --name 53 --logFilePath ${output_path} --requestType request --debugOn --debugLevel 100 --arrivalRate "${arrivalRate}" --config ${config}"  >${local_output_path}53.log &
nohup ssh ${replica9}   -i ${cert}   "pkill client; ./${ctl_path} --name 54 --logFilePath ${output_path} --requestType request --debugOn --debugLevel 100 --arrivalRate "${arrivalRate}" --config ${config}"  >${local_output_path}54.log &
nohup ssh ${replica10}  -i ${cert}   "pkill client; ./${ctl_path} --name 55 --logFilePath ${output_path} --requestType request --debugOn --debugLevel 100 --arrivalRate "${arrivalRate}" --config ${config}"  >${local_output_path}55.log &

sleep 120

echo "Completed Client[s]"

nohup ssh ${replica6} -i ${cert}   "pkill client; ./${ctl_path} --name 51 --logFilePath ${output_path} --requestType status --operationType 2  --debugOn --debugLevel 100  --config ${config}" >${local_output_path}status2.log &

sleep 20

scp -i ${cert} ${replica1}:${output_path}1-consensus.txt ${local_output_path}1-consensus.txt
scp -i ${cert} ${replica2}:${output_path}2-consensus.txt ${local_output_path}2-consensus.txt
scp -i ${cert} ${replica3}:${output_path}3-consensus.txt ${local_output_path}3-consensus.txt
scp -i ${cert} ${replica4}:${output_path}4-consensus.txt ${local_output_path}4-consensus.txt
scp -i ${cert} ${replica5}:${output_path}5-consensus.txt ${local_output_path}5-consensus.txt

python3 integration-test/python/overlay-test.py ${local_output_path}/1-consensus.txt ${local_output_path}/2-consensus.txt ${local_output_path}/3-consensus.txt ${local_output_path}/4-consensus.txt ${local_output_path}/5-consensus.txt

for index in "${!replicas[@]}";
do
  sshpass ssh "${replicas[${index}]}"  -i ${cert}  "pkill replica; pkill client"
done

sleep 15

echo "Finish test"




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