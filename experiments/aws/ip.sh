cert="/home/ubuntu/Pictures/pasindu"
username=ubuntu
replica1_name=18.227.0.43
replica1=${username}@${replica1_name}

replica2_name=3.144.112.172
replica2=${username}@${replica2_name}

replica3_name=54.187.140.34
replica3=${username}@${replica3_name}

replica4_name=52.12.180.108
replica4=${username}@${replica4_name}

replica5_name=13.244.92.79
replica5=${username}@${replica5_name}

replica6_name=13.246.15.95
replica6=${username}@${replica6_name}

replica7_name=43.198.246.114
replica7=${username}@${replica7_name}

replica8_name=43.198.182.98
replica8=${username}@${replica8_name}

replica9_name=15.160.22.188
replica9=${username}@${replica9_name}

replica10_name=15.161.132.146
replica10=${username}@${replica10_name}

replicas=(${replica1} ${replica2} ${replica3} ${replica4} ${replica5} ${replica6} ${replica7} ${replica8} ${replica9} ${replica10})
replica_names=(${replica1_name} ${replica2_name} ${replica3_name} ${replica4_name} ${replica5_name} ${replica6_name} ${replica7_name} ${replica8_name} ${replica9_name} ${replica10_name})