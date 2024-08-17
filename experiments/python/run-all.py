import csv
import sys
import os
import re

bash_file = sys.argv[1]
input_csv = sys.argv[2]
output_root = sys.argv[3]
output_csv = sys.argv[4]
num_replicas = int(sys.argv[5])

consensus_only = 'true'
initial_delay_secs = '0'
initial_delay_nanos = '0'

lines = []

csvfile = open(output_csv, 'w', newline='')
csvwriter = csv.writer(csvfile)

headers = ["wave_length", "number_of_leaders", "enable_pipelining", "enable_synchronizer", "load",
           "transaction_size"]
for i in range(num_replicas):
    headers.extend(["cl_" + str(i) + "_median_latency", "cl_" + str(i) + "_average_latency",
                    "cl_" + str(i) + "_percentile_latency", "cl_" + str(i) + "_throughput"])
csvwriter.writerow(headers)


def check_file_format_and_lines(filename: str, expected_lines: int) -> bool:
    pattern = re.compile(
        r"Client: \d+ : Median Latency: \d+(\.\d+)? microseconds, Average Latency: \d+(\.\d+)? microseconds, "
        r"99th Percentile Latency: \d+(\.\d+)? microseconds, Throughput: \d+(\.\d+)? requests per second"
    )

    try:
        with open(filename, 'r') as file:
            lines = file.readlines()

        format_correct = all(pattern.match(line.strip()) for line in lines)
        line_count_correct = len(lines) == expected_lines

        return format_correct and line_count_correct

    except FileNotFoundError:
        print(f"File {filename} not found.")
        return False


def extract_latencies_and_throughput(filename: str, expected_lines: int) -> list:
    result = []

    try:
        with open(filename, 'r') as file:
            lines = file.readlines()

        if len(lines) != expected_lines:
            print(f"File {filename} does not have the expected number of lines.")
            return result

        for line in lines:
            parts = line.strip().split(", ")
            median_latency = parts[0].split(": ")[3].split(" ")[0]
            average_latency = parts[1].split(": ")[1].split(" ")[0]
            percentile_latency = parts[2].split(": ")[1].split(" ")[0]
            throughput = parts[3].split(": ")[1].split(" ")[0]

            result.extend([median_latency, average_latency, percentile_latency, throughput])

        return result

    except FileNotFoundError:
        print(f"File {filename} not found.")
        return []


with open(input_csv, mode='r') as file:
    csv_reader = csv.reader(file)
    for row in csv_reader:
        wave_length = row[0]
        number_of_leaders = row[1]
        enable_pipelining = row[2]
        enable_synchronizer = row[3]
        load = row[4]
        transaction_size = row[5]

        complete = False
        while not complete:
            command = (
                f"/bin/bash {bash_file} {wave_length} {number_of_leaders} {enable_pipelining} "
                f"{consensus_only} {enable_synchronizer} {initial_delay_secs} {initial_delay_nanos} "
                f"{load} {transaction_size} {0}"
            )

            exit_code = os.system(command)

            if exit_code != 0:
                print(f"Command failed with exit code {exit_code}: {command}", file=sys.stderr)
                continue
            else:
                print(f"Command succeeded: {command}")

            file_path = output_root + f"/{wave_length}/{number_of_leaders}/pipelining-{enable_pipelining}/synchronizer-{enable_synchronizer}/{load}/{transaction_size}/{0}/output.txt"
            if os.path.exists(file_path):
                if check_file_format_and_lines(file_path, num_replicas):
                    stats = extract_latencies_and_throughput(file_path, num_replicas)
                    if len(stats) > 0:
                        new_entry = [wave_length, number_of_leaders, enable_pipelining, enable_synchronizer, load,
                                     transaction_size]
                        new_entry.extend(stats)
                        lines.append(new_entry)
                        csvwriter.writerow(new_entry)
                        csvfile.flush()
                        complete = True
                    else:
                        print(f"File {file_path} output passing failed.")
                else:
                    print(f"File {file_path} does not have the expected format or number of lines.")
            else:
                print(f"File {file_path} not found.")
