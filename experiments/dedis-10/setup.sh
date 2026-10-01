# Copyright (c) Mysten Labs, Inc.
# SPDX-License-Identifier: Apache-2.0

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_ip.sh>"
    exit 1
fi

ip_sh_path="$1"

. "$ip_sh_path"

rm -r logs/dedis-10/ ; mkdir -p logs/dedis-10/

remote_home_path="/home/${username}/a_mysticeti/"
reset_directory="sudo rm -r ${remote_home_path}; mkdir -p ${remote_home_path}logs/"
kill_instances="pkill -f mysticeti ; pkill -f mysticeti"
install_dependencies="sudo apt-get update"

# build the binary in a remote replica, uncomment when needed
sshpass ssh -o StrictHostKeyChecking=no  "${replicas[0]}" -i ${cert} "rm -r async-mystecity; git clone https://github.com/PasinduTennage/async-mystecity; cd async-mystecity; git checkout consensus-rework; sudo apt-get install libfontconfig1-dev; source /home/${username}/.cargo/env; cargo build --release;"
#sshpass ssh "${replicas[0]}" -i ${cert} "rm /home/${username}/async-mystecity/target/release/mysticeti; cd async-mystecity; git checkout consensus-rework; git pull origin consensus-rework;  source /home/${username}/.cargo/env; cargo build --release;"
scp -i ${cert} "${replicas[0]}":/home/${username}/async-mystecity/target/release/mysticeti logs/dedis-10/mysticeti


for index in "${!replicas[@]}";
do
    echo "copying files to replica ${index}"
    sshpass ssh -o StrictHostKeyChecking=no  "${replicas[${index}]}" -i ${cert} "${reset_directory};${kill_instances};${install_dependencies}"
    scp -i ${cert} logs/dedis-10/mysticeti "${replicas[${index}]}":${remote_home_path} # first download from replica 0
done

echo "setup complete"
