pwd=$(pwd)
. "${pwd}"/scripts/ip.sh

cargo build

rm -r logs/ ; mkdir logs/

remote_home_path="/home/${username}/a_mysticeti/"
reset_directory="sudo rm -r ${remote_home_path}; mkdir -p ${remote_home_path}logs/"
kill_instances="pkill -f mysticeti ; pkill -f mysticeti"
install_dependencies="sudo apt-get update"

# build the binary in a remote replica
sshpass ssh "${replicas[0]}" -i ${cert} "git clone https://github.com/PasinduTennage/async-mystecity; cd async-mystecity; cargo build --release"
scp -i ${cert} "${replicas[0]}":/home/${username}/async-mystecity/target/release/mysticeti logs/mysticeti


for index in "${!replicas[@]}";
do
    echo "copying files to replica ${index}"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${reset_directory};${kill_instances};${install_dependencies}"
    scp -i ${cert} logs/mysticeti "${replicas[${index}]}":${remote_home_path}
    scp -i ${cert} scripts/node-parameters.yml   "${replicas[${index}]}":${remote_home_path}
    scp -i ${cert} scripts/client-parameters.yml "${replicas[${index}]}":${remote_home_path}
    sshpass ssh "${replicas[${index}]}" -i ${cert} "./a_mysticeti/mysticeti benchmark-genesis --ips ${replicas} --working-directory ${remote_home_path} --node-parameters-path ${remote_home_path}node-parameters.yml"
done

echo "setup complete"