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
. "${pwd}"/experiments/aws/ip-best-50.sh

python3 experiments/python/genrate-configs.py --wave_length "${wave_length}" --number_of_leaders "${number_of_leaders}" --enable_pipelining "${enable_pipelining}" --consensus_only "${consensus_only}" --enable_synchronizer "${enable_synchronizer}" --initial_delay_secs "${initial_delay_secs}" --initial_delay_nanos "${initial_delay_nanos}" --load "${load}" --transaction_size "${transaction_size}" --output_dir "logs/dedis-10/"

remote_home_path="/home/${username}/a_mysticeti/"
kill_instances="pkill -f mysticeti ; pkill -f mysticeti"
remote_replica_path="/a_mysticeti/mysticeti"


for index in "${!replicas[@]}";
do
    echo "copying configs to replica ${index}"
    scp -i ${cert} logs/dedis-10/node-parameters.yml   "${replicas[${index}]}":"${remote_home_path}" &
    scp -i ${cert} logs/dedis-10/client-parameters.yml "${replicas[${index}]}":"${remote_home_path}" &
    wait
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${kill_instances}; rm ${remote_home_path}storage-${index}/wal; .${remote_replica_path} benchmark-genesis --ips ${replica1_name}  ${replica2_name} ${replica3_name} ${replica4_name} ${replica5_name} ${replica6_name} ${replica7_name} ${replica8_name} ${replica9_name} ${replica10_name} ${replica11_name}  ${replica12_name} ${replica13_name} ${replica14_name} ${replica15_name} ${replica16_name} ${replica17_name} ${replica18_name} ${replica19_name} ${replica20_name} ${replica21_name}  ${replica22_name} ${replica23_name} ${replica24_name} ${replica25_name} ${replica26_name} ${replica27_name} ${replica28_name} ${replica29_name} ${replica30_name} ${replica31_name}  ${replica32_name} ${replica33_name} ${replica34_name} ${replica35_name} ${replica36_name} ${replica37_name} ${replica38_name} ${replica39_name} ${replica40_name} ${replica41_name}  ${replica42_name} ${replica43_name} ${replica44_name} ${replica45_name} ${replica46_name} ${replica47_name} ${replica48_name} ${replica49_name} ${replica50_name} --working-directory ${remote_home_path} --node-parameters-path ${remote_home_path}node-parameters.yml"
done

sleep 5
rm nohup.out

local_output_path="logs/dedis-10/${wave_length}/${number_of_leaders}/pipelining-${enable_pipelining}/synchronizer-${enable_synchronizer}/${load}/${transaction_size}/${iteration}/"

rm -r "${local_output_path}"; mkdir -p "${local_output_path}"

echo "starting replicas"

nohup ssh "${replica1}"   -i ${cert}   ".${remote_replica_path} run --authority 0  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-0.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v0.log.ansi &
nohup ssh "${replica2}"   -i ${cert}   ".${remote_replica_path} run --authority 1  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-1.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v1.log.ansi &
nohup ssh "${replica3}"   -i ${cert}   ".${remote_replica_path} run --authority 2  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-2.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v2.log.ansi &
nohup ssh "${replica4}"   -i ${cert}   ".${remote_replica_path} run --authority 3  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-3.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v3.log.ansi &
nohup ssh "${replica5}"   -i ${cert}   ".${remote_replica_path} run --authority 4  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-4.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v4.log.ansi &
nohup ssh "${replica6}"   -i ${cert}   ".${remote_replica_path} run --authority 5  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-5.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v5.log.ansi &
nohup ssh "${replica7}"   -i ${cert}   ".${remote_replica_path} run --authority 6  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-6.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v6.log.ansi &
nohup ssh "${replica8}"   -i ${cert}   ".${remote_replica_path} run --authority 7  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-7.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v7.log.ansi &
nohup ssh "${replica9}"   -i ${cert}   ".${remote_replica_path} run --authority 8  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-8.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v8.log.ansi &
nohup ssh "${replica10}"  -i ${cert}   ".${remote_replica_path} run --authority 9  --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-9.yaml  --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v9.log.ansi &
nohup ssh "${replica11}"  -i ${cert}   ".${remote_replica_path} run --authority 10 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-10.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v10.log.ansi &
nohup ssh "${replica12}"  -i ${cert}   ".${remote_replica_path} run --authority 11 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-11.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v11.log.ansi &
nohup ssh "${replica13}"  -i ${cert}   ".${remote_replica_path} run --authority 12 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-12.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v12.log.ansi &
nohup ssh "${replica14}"  -i ${cert}   ".${remote_replica_path} run --authority 13 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-13.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v13.log.ansi &
nohup ssh "${replica15}"  -i ${cert}   ".${remote_replica_path} run --authority 14 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-14.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v14.log.ansi &
nohup ssh "${replica16}"  -i ${cert}   ".${remote_replica_path} run --authority 15 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-15.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v15.log.ansi &
nohup ssh "${replica17}"  -i ${cert}   ".${remote_replica_path} run --authority 16 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-16.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v16.log.ansi &
nohup ssh "${replica18}"  -i ${cert}   ".${remote_replica_path} run --authority 17 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-17.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v17.log.ansi &
nohup ssh "${replica19}"  -i ${cert}   ".${remote_replica_path} run --authority 18 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-18.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v18.log.ansi &
nohup ssh "${replica20}"  -i ${cert}   ".${remote_replica_path} run --authority 19 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-19.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v19.log.ansi &
nohup ssh "${replica21}"  -i ${cert}   ".${remote_replica_path} run --authority 20 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-20.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v20.log.ansi &
nohup ssh "${replica22}"  -i ${cert}   ".${remote_replica_path} run --authority 21 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-21.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v21.log.ansi &
nohup ssh "${replica23}"  -i ${cert}   ".${remote_replica_path} run --authority 22 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-22.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v22.log.ansi &
nohup ssh "${replica24}"  -i ${cert}   ".${remote_replica_path} run --authority 23 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-23.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v23.log.ansi &
nohup ssh "${replica25}"  -i ${cert}   ".${remote_replica_path} run --authority 24 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-24.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v24.log.ansi &
nohup ssh "${replica26}"  -i ${cert}   ".${remote_replica_path} run --authority 25 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-25.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v25.log.ansi &
nohup ssh "${replica27}"  -i ${cert}   ".${remote_replica_path} run --authority 26 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-26.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v26.log.ansi &
nohup ssh "${replica28}"  -i ${cert}   ".${remote_replica_path} run --authority 27 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-27.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v27.log.ansi &
nohup ssh "${replica29}"  -i ${cert}   ".${remote_replica_path} run --authority 28 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-28.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v28.log.ansi &
nohup ssh "${replica30}"  -i ${cert}   ".${remote_replica_path} run --authority 29 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-29.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v29.log.ansi &
nohup ssh "${replica31}"  -i ${cert}   ".${remote_replica_path} run --authority 30 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-30.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v30.log.ansi &
nohup ssh "${replica32}"  -i ${cert}   ".${remote_replica_path} run --authority 31 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-31.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v31.log.ansi &
nohup ssh "${replica33}"  -i ${cert}   ".${remote_replica_path} run --authority 32 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-32.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v32.log.ansi &
nohup ssh "${replica34}"  -i ${cert}   ".${remote_replica_path} run --authority 33 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-33.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v33.log.ansi &
nohup ssh "${replica35}"  -i ${cert}   ".${remote_replica_path} run --authority 34 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-34.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v34.log.ansi &
nohup ssh "${replica36}"  -i ${cert}   ".${remote_replica_path} run --authority 35 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-35.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v35.log.ansi &
nohup ssh "${replica37}"  -i ${cert}   ".${remote_replica_path} run --authority 36 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-36.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v36.log.ansi &
nohup ssh "${replica38}"  -i ${cert}   ".${remote_replica_path} run --authority 37 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-37.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v37.log.ansi &
nohup ssh "${replica39}"  -i ${cert}   ".${remote_replica_path} run --authority 38 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-38.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v38.log.ansi &
nohup ssh "${replica40}"  -i ${cert}   ".${remote_replica_path} run --authority 39 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-39.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v39.log.ansi &
nohup ssh "${replica41}"  -i ${cert}   ".${remote_replica_path} run --authority 40 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-40.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v40.log.ansi &
nohup ssh "${replica42}"  -i ${cert}   ".${remote_replica_path} run --authority 41 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-41.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v41.log.ansi &
nohup ssh "${replica43}"  -i ${cert}   ".${remote_replica_path} run --authority 42 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-42.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v42.log.ansi &
nohup ssh "${replica44}"  -i ${cert}   ".${remote_replica_path} run --authority 43 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-43.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v43.log.ansi &
nohup ssh "${replica45}"  -i ${cert}   ".${remote_replica_path} run --authority 44 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-44.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v44.log.ansi &
nohup ssh "${replica46}"  -i ${cert}   ".${remote_replica_path} run --authority 45 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-45.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v45.log.ansi &
nohup ssh "${replica47}"  -i ${cert}   ".${remote_replica_path} run --authority 46 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-46.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v46.log.ansi &
nohup ssh "${replica48}"  -i ${cert}   ".${remote_replica_path} run --authority 47 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-47.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v47.log.ansi &
nohup ssh "${replica49}"  -i ${cert}   ".${remote_replica_path} run --authority 48 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-48.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v48.log.ansi &
nohup ssh "${replica50}"  -i ${cert}   ".${remote_replica_path} run --authority 49 --committee-path ${remote_home_path}committee.yaml --public-config-path ${remote_home_path}public-config.yaml --private-config-path ${remote_home_path}private-config-49.yaml --client-parameters-path ${remote_home_path}client-parameters.yml" >${local_output_path}v49.log.ansi &


sleep 125

for index in "${!replicas[@]}";
do
    echo "killing instance"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${kill_instances}" &
done
wait

home_path="/home/${username}/"

scp -i ${cert} ${replica1}:${home_path}client-times-0.txt    ${local_output_path}client-times-0.txt &
scp -i ${cert} ${replica2}:${home_path}client-times-1.txt    ${local_output_path}client-times-1.txt &
scp -i ${cert} ${replica3}:${home_path}client-times-2.txt    ${local_output_path}client-times-2.txt &
scp -i ${cert} ${replica4}:${home_path}client-times-3.txt    ${local_output_path}client-times-3.txt &
scp -i ${cert} ${replica5}:${home_path}client-times-4.txt    ${local_output_path}client-times-4.txt &
wait

output_file=${local_output_path}output.txt

python3 experiments/python/client-stats.py ${local_output_path}client-times-0.txt ${initial_delay_secs}  0 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-1.txt ${initial_delay_secs}  1 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-2.txt ${initial_delay_secs}  2 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-3.txt ${initial_delay_secs}  3 >> ${output_file}
python3 experiments/python/client-stats.py ${local_output_path}client-times-4.txt ${initial_delay_secs}  4 >> ${output_file}