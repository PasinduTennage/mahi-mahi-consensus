pwd=$(pwd)
. "${pwd}"/experiments/ip.sh

rm client/bin/client
rm replica/bin/replica

go build -v -o ./client/bin/client ./client/
go build -v -o ./replica/bin/replica ./replica/

rm -r logs/ ; mkdir logs/

reset_directory="sudo rm -r /home/${username}/baxos; mkdir -p /home/${username}/baxos/logs/"
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