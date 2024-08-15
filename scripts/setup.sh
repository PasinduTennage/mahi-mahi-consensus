pwd=$(pwd)
. "${pwd}"/scripts/ip.sh

cargo build

rm -r logs/ ; mkdir logs/

reset_directory="sudo rm -r /home/${username}/amystecity; mkdir -p /home/${username}/amystecity/logs/"
kill_instances="pkill replica ; pkill client"

remote_home_path="/home/${username}/baxos/"



for index in "${!replicas[@]}";
do
    echo "copying files to replica ${index}"
    sshpass ssh "${replicas[${index}]}" -i ${cert} "${reset_directory};${kill_instances}"

    scp -i ${cert} replica/bin/replica "${replicas[${index}]}":${remote_home_path}
    scp -i ${cert} client/bin/client   "${replicas[${index}]}":${remote_home_path}

    scp -i ${cert} configuration/remote-configuration.yml "${replicas[${index}]}":${remote_home_path}
done

echo "setup complete"