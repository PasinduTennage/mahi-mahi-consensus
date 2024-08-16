pwd=$(pwd)
. "${pwd}"/scripts/ip.sh

cargo build

rm -r logs/ ; mkdir logs/

remote_home_path="/home/${username}/a_mysticeti/"
reset_directory="sudo rm -r ${remote_home_path}; mkdir -p ${remote_home_path}logs/"
kill_instances="pkill -f mysticeti ; pkill -f mysticeti"
install_dependencies="sudo apt-get update"

# build the binary in a remote replica, uncomment when needed
#sshpass ssh "${replicas[0]}" -i ${cert} "rm -r async-mystecity; git clone https://github.com/PasinduTennage/async-mystecity; cd async-mystecity; git checkout consensus-rework; sudo apt-get install libfontconfig1-dev; source $HOME/.cargo/env; cargo build --release;"
sshpass ssh "${replicas[0]}" -i ${cert} "cd async-mystecity; git pull origin consensus-rework; git checkout consensus-rework; source $HOME/.cargo/env; cargo build;"
scp -i ${cert} "${replicas[0]}":/home/${username}/async-mystecity/target/release/mysticeti logs/mysticeti


for index in "${!replicas[@]}";
do
    echo "copying files to replica ${index}"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${reset_directory};${kill_instances};${install_dependencies}"
    scp -i ${cert} logs/mysticeti "${replicas[${index}]}":${remote_home_path} # first download from replica 0
    scp -i ${cert} scripts/node-parameters.yml   "${replicas[${index}]}":${remote_home_path}
    scp -i ${cert} scripts/client-parameters.yml "${replicas[${index}]}":${remote_home_path}
    sshpass ssh "${replicas[${index}]}" -i ${cert} "./a_mysticeti/mysticeti benchmark-genesis --ips ${replica1_name} ${replica2_name} ${replica3_name} ${replica4_name} ${replica5_name} ${replica6_name} ${replica7_name} ${replica8_name} ${replica9_name} ${replica10_name} --working-directory ${remote_home_path} --node-parameters-path ${remote_home_path}node-parameters.yml"
done

echo "setup complete"