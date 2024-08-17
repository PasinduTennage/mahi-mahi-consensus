import numpy as np
import sys

if len(sys.argv) < 4:
    print("Usage: python3 latency_calculator.py <file_name> <initial delay> <client>")
    sys.exit(1)

file_name = sys.argv[1]
init_delay_secs = int(sys.argv[2])
client = sys.argv[3]

latencies = []
row_count = 0

with open(file_name, 'r') as file:
    for line in file:
        if line.strip():
            if len(line.split(","))!=2:
                continue
            start_time, end_time = map(int, line.split(","))
            if start_time < (60 + init_delay_secs + 1) * 1000000:
                latency = end_time - start_time
                latencies.append(latency)
                row_count += 1

if latencies:
    median_latency = np.median(latencies)
    average_latency = np.mean(latencies)
    percentile_99_latency = np.percentile(latencies, 99)
    print(f"Client: {client} : "
          f"Median Latency: {median_latency} microseconds, "
          f"Average Latency: {average_latency} microseconds, "
          f"99th Percentile Latency: {percentile_99_latency} microseconds, "
          f"Throughput: {float(row_count)/60.0} requests per second")
else:
    print("No valid entries found with start time less than 60000000.")
