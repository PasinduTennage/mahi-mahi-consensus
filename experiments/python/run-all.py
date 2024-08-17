import csv
import sys
import os


bash_file = sys.argv[1]
input_csv = sys.argv[2]


consensus_only = 'true'
initial_delay_secs = '0'
initial_delay_nanos = '0'


with open(input_csv, mode='r') as file:
    csv_reader = csv.reader(file)
    for row in csv_reader:
        wave_length = row[0]
        number_of_leaders = row[1]
        enable_pipelining = row[2]
        enable_synchronizer = row[3]
        load = row[4]
        transaction_size = row[5]

        for i in range(1):
            command = (
                f"/bin/bash {bash_file} {wave_length} {number_of_leaders} {enable_pipelining} "
                f"{consensus_only} {enable_synchronizer} {initial_delay_secs} {initial_delay_nanos} "
                f"{load} {transaction_size} {i}"
            )

            exit_code = os.system(command)

            if exit_code != 0:
                print(f"Command failed with exit code {exit_code}: {command}", file=sys.stderr)
            else:
                print(f"Command succeeded: {command}")
