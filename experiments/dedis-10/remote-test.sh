wave_length=$1
number_of_leaders=$2
enable_pipelining=$3
consensus_only=$4
enable_synchronizer=$5
initial_delay_secs=$6
initial_delay_nanos=$7
load=$8
transaction_size=$9
iteration=${10}

pwd=$(pwd)
. "${pwd}"/experiments/aws/ip.sh

python3 experiments/python/genrate-configs.py --wave_length "${wave_length}" --number_of_leaders "${number_of_leaders}" --enable_pipelining "${enable_pipelining}" --consensus_only "${consensus_only}" --enable_synchronizer "${enable_synchronizer}" --initial_delay_secs "${initial_delay_secs}" --initial_delay_nanos "${initial_delay_nanos}" --load "${load}" --transaction_size "${transaction_size}" --output_dir "logs/dedis-10/"

remote_home_path="/home/${username}/a_mysticeti/"
kill_instances="pkill -f mysticeti ; pkill -f mysticeti"
remote_replica_path="/a_mysticeti/mysticeti"


for index in "${!replicas[@]}";
do
    echo "copying configs to replica ${index}"
    scp -i ${cert} logs/dedis-10/node-parameters.yml   "${replicas[${index}]}":"${remote_home_path}"
    scp -i ${cert} logs/dedis-10/client-parameters.yml "${replicas[${index}]}":"${remote_home_path}"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${kill_instances}"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "rm ${remote_home_path}storage-${index}/wal"
    sshpass ssh "${replicas[${index}]}" -i ${cert} ".${remote_replica_path} benchmark-genesis --ips ${replica1_name}  ${replica2_name} ${replica3_name} ${replica4_name} ${replica5_name} ${replica6_name} ${replica7_name} ${replica8_name} ${replica9_name} ${replica10_name} --working-directory ${remote_home_path} --node-parameters-path ${remote_home_path}node-parameters.yml"
done

sleep 5
rm nohup.out

local_output_path="logs/dedis-10/${wave_length}/${number_of_leaders}/pipelining-${enable_pipelining}/synchronizer-${enable_synchronizer}/${load}/${transaction_size}/${iteration}/"

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

home_path="/home/${username}/"

scp -i ${cert} ${replica1}:${home_path}client-times-0.txt  ${local_output_path}client-times-0.txt
scp -i ${cert} ${replica2}:${home_path}client-times-1.txt  ${local_output_path}client-times-1.txt
scp -i ${cert} ${replica3}:${home_path}client-times-2.txt  ${local_output_path}client-times-2.txt
scp -i ${cert} ${replica4}:${home_path}client-times-3.txt  ${local_output_path}client-times-3.txt
scp -i ${cert} ${replica5}:${home_path}client-times-4.txt  ${local_output_path}client-times-4.txt
scp -i ${cert} ${replica6}:${home_path}client-times-5.txt  ${local_output_path}client-times-5.txt
scp -i ${cert} ${replica7}:${home_path}client-times-6.txt  ${local_output_path}client-times-6.txt
scp -i ${cert} ${replica8}:${home_path}client-times-7.txt  ${local_output_path}client-times-7.txt
scp -i ${cert} ${replica9}:${home_path}client-times-8.txt  ${local_output_path}client-times-8.txt
scp -i ${cert} ${replica10}:${home_path}client-times-9.txt ${local_output_path}client-times-9.txt

output_file=${local_output_path}output.txt

python3 experiments/python/client-stats.py ${local_output_path}client-times-0.txt ${initial_delay_secs} 0 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-1.txt ${initial_delay_secs} 1 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-2.txt ${initial_delay_secs} 2 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-3.txt ${initial_delay_secs} 3 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-4.txt ${initial_delay_secs} 4 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-5.txt ${initial_delay_secs} 5 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-6.txt ${initial_delay_secs} 6 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-7.txt ${initial_delay_secs} 7 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-8.txt ${initial_delay_secs} 8 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-9.txt ${initial_delay_secs} 9 >> ${output_file}