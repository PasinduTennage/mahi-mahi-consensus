pwd=$(pwd)
. "${pwd}"/scripts/ip.sh

cargo build

rm -r logs/ ; mkdir logs/

remote_home_path="/home/${username}/amystecity/"
reset_directory="sudo rm -r ${remote_home_path}; mkdir -p ${remote_home_path}logs/"
kill_instances="pkill -f mysticeti ; pkill -f mysticeti"

for index in "${!replicas[@]}";
do
    echo "copying files to replica ${index}"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${reset_directory};${kill_instances}"
    scp -i ${cert} target/debug/mysticeti "${replicas[${index}]}":${remote_home_path}
    scp -i ${cert} scripts/node-parameters.yml   "${replicas[${index}]}":${remote_home_path}
    scp -i ${cert} scripts/client-parameters.yml "${replicas[${index}]}":${remote_home_path}
    sshpass ssh "${replicas[${index}]}" -i ${cert} "./${remote_home_path}mysticeti benchmark-genesis --ips ${replicas} --working-directory ${remote_home_path} --node-parameters-path ${remote_home_path}node-parameters.yml"
done

echo "setup complete"