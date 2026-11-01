# Copyright (c) Mysten Labs, Inc.
# SPDX-License-Identifier: Apache-2.0

cert="/home/ubuntu/Pictures/pasindu"
username=ubuntu
replica1_name=18.218.29.206
replica1=${username}@${replica1_name}

replica2_name=3.147.7.208
replica2=${username}@${replica2_name}

replica3_name=54.245.5.197
replica3=${username}@${replica3_name}

replica4_name=34.209.240.144
replica4=${username}@${replica4_name}

replica5_name=13.245.71.218
replica5=${username}@${replica5_name}

replica6_name=13.246.139.234
replica6=${username}@${replica6_name}

replica7_name=16.163.95.16
replica7=${username}@${replica7_name}

replica8_name=16.163.104.181
replica8=${username}@${replica8_name}

replica9_name=15.160.209.135
replica9=${username}@${replica9_name}

replica10_name=15.160.33.192
replica10=${username}@${replica10_name}

replicas=(${replica1} ${replica2} ${replica3} ${replica4} ${replica5} ${replica6} ${replica7} ${replica8} ${replica9} ${replica10})
replica_names=(${replica1_name} ${replica2_name} ${replica3_name} ${replica4_name} ${replica5_name} ${replica6_name} ${replica7_name} ${replica8_name} ${replica9_name} ${replica10_name})
