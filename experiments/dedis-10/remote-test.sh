wave_length=$1
number_of_leaders=$2
enable_pipelining=$3
consensus_only=$4
enable_synchronizer=$5
initial_delay_secs=$6
initial_delay_nanos=$7
load=$8
transaction_size=$9

pwd=$(pwd)
. "${pwd}"/experiments/dedis-10/ip.sh

python3 experiments/dedis-10/genrate-configs.py --wave_length "${wave_length}" --number_of_leaders "${number_of_leaders}" --enable_pipelining "${enable_pipelining}" --consensus_only "${consensus_only}" --enable_synchronizer "${enable_synchronizer}" --initial_delay_secs "${initial_delay_secs}" --initial_delay_nanos "${initial_delay_nanos}" --load "${load}" --transaction_size "${transaction_size}" --output_dir "logs/dedis-10/"

remote_home_path="/home/${username}/a_mysticeti/"
kill_instances="pkill -f mysticeti ; pkill -f mysticeti"
remote_replica_path="/a_mysticeti/mysticeti"


for index in "${!replicas[@]}";
do
    echo "copying configs to replica ${index}"
    scp -i ${cert} logs/dedis-10/node-parameters.yml   "${replicas[${index}]}":"${remote_home_path}"
    scp -i ${cert} logs/dedis-10/client-parameters.yml "${replicas[${index}]}":"${remote_home_path}"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${kill_instances}"
    sshpass ssh "${replicas[${index}]}" -i ${cert} ".${remote_replica_path} benchmark-genesis --ips "${replica1_name}" "${replica2_name}" "${replica3_name}" "${replica4_name}" "${replica5_name}" "${replica6_name}" "${replica7_name}" "${replica8_name}" "${replica9_name}" "${replica10_name} --working-directory "${remote_home_path}" --node-parameters-path "${remote_home_path}"node-parameters.yml
done

sleep 5
rm nohup.out

local_output_path="logs/dedis-10/"

rm -r "${local_output_path}"; mkdir -p "${local_output_path}"

echo "starting replicas"

nohup ssh "${replica1}"   -i ${cert}   ".${remote_replica_path} run --authority 0 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-0.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v0.log.ansi &
nohup ssh "${replica2}"   -i ${cert}   ".${remote_replica_path} run --authority 1 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-1.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v1.log.ansi &
nohup ssh "${replica3}"   -i ${cert}   ".${remote_replica_path} run --authority 2 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-2.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v2.log.ansi &
nohup ssh "${replica4}"   -i ${cert}   ".${remote_replica_path} run --authority 3 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-3.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v3.log.ansi &
nohup ssh "${replica5}"   -i ${cert}   ".${remote_replica_path} run --authority 4 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-4.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v4.log.ansi &
nohup ssh "${replica6}"   -i ${cert}   ".${remote_replica_path} run --authority 5 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-5.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v5.log.ansi &
nohup ssh "${replica7}"   -i ${cert}   ".${remote_replica_path} run --authority 6 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-6.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v6.log.ansi &
nohup ssh "${replica8}"   -i ${cert}   ".${remote_replica_path} run --authority 7 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-7.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v7.log.ansi &
nohup ssh "${replica9}"   -i ${cert}   ".${remote_replica_path} run --authority 8 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-8.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v8.log.ansi &
nohup ssh "${replica10}"  -i ${cert}   ".${remote_replica_path} run --authority 9 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-9.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v9.log.ansi &


sleep 120

for index in "${!replicas[@]}";
do
    echo "killing instance"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${kill_instances}"
done

#
#scp -i ${cert} ${replica1}:${output_path}1-consensus.txt ${local_output_path}1-consensus.txt
#scp -i ${cert} ${replica2}:${output_path}2-consensus.txt ${local_output_path}2-consensus.txt
#scp -i ${cert} ${replica3}:${output_path}3-consensus.txt ${local_output_path}3-consensus.txt
#scp -i ${cert} ${replica4}:${output_path}4-consensus.txt ${local_output_path}4-consensus.txt
#scp -i ${cert} ${replica5}:${output_path}5-consensus.txt ${local_output_path}5-consensus.txt
#
#python3 integration-test/python/overlay-test.py ${local_output_path}/1-consensus.txt ${local_output_path}/2-consensus.txt ${local_output_path}/3-consensus.txt ${local_output_path}/4-consensus.txt ${local_output_path}/5-consensus.txt
#
#for index in "${!replicas[@]}";
#do
#  sshpass ssh "${replicas[${index}]}"  -i ${cert}  "pkill replica; pkill client"
#done
#
#sleep 15
#
#echo "Finish test"
#
#
#
#
#export RUST_LOG=warn,mysticeti_core::consensus=debug,mysticeti_core::net_sync=warn,mysticeti_core::core=debug
#
#
#sleep 60
#
#
#
#pkill -f mysticeti
#
#sleep 5
#
#python3 scripts/block-create-test.py v0.log.ansi v1.log.ansi v2.log.ansi v3.log.ansi
#python3 scripts/commit-test.py v0.log.ansi v1.log.ansi v2.log.ansi v3.log.ansi
#python3 scripts/simple-commit-count.py v0.log.ansi v1.log.ansi v2.log.ansi v3.log.ansi