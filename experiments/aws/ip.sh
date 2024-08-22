cert="/home/pasindu/Pictures/pasindu"
username=ubuntu
replica1_name=3.16.124.171
replica1=${username}@${replica1_name}

replica2_name=3.134.116.167
replica2=${username}@${replica2_name}

replica3_name=44.242.227.51
replica3=${username}@${replica3_name}

replica4_name=54.69.151.131
replica4=${username}@${replica4_name}

replica5_name=13.246.11.206
replica5=${username}@${replica5_name}

replica6_name=13.245.5.222
replica6=${username}@${replica6_name}

replica7_name=18.163.2.2
replica7=${username}@${replica7_name}

replica8_name=18.163.46.14
replica8=${username}@${replica8_name}

replica9_name=15.160.16.67
replica9=${username}@${replica9_name}

replica10_name=15.161.126.21
replica10=${username}@${replica10_name}

replicas=(${replica1} ${replica2} ${replica3} ${replica4} ${replica5} ${replica6} ${replica7} ${replica8} ${replica9} ${replica10})
replica_names=(${replica1_name} ${replica2_name} ${replica3_name} ${replica4_name} ${replica5_name} ${replica6_name} ${replica7_name} ${replica8_name} ${replica9_name} ${replica10_name})