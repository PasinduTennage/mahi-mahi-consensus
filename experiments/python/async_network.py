import os
import random
import time
import argparse

parser = argparse.ArgumentParser(description="Network traffic attack simulation script.")
parser.add_argument("--attack_level", type=int, help="Attack level (1-100)")
parser.add_argument("--duration", type=int, help="Duration to run the script (in seconds)")
parser.add_argument("--device", type=str, help="Device name")

# Parse arguments
args = parser.parse_args()

print(
    f"Running attack simulation with attack level: {args.attack_level} and duration: {args.duration} seconds for "
    f"device: {args.device}")

attack_level = args.attack_level
duration = args.duration


def apply_traffic_delay():
    # Apply traffic delay of 500ms
    os.system("sudo tc qdisc add dev " + args.device + " root netem delay 500ms")


def reset_traffic_delay():
    # Reset traffic rules
    os.system("sudo tc qdisc del dev " + args.device + " root netem")


def main():
    start_time = time.time()
    counter = 0
    reset_traffic_delay()
    while (time.time() - start_time) < duration:
        # Generate a random number between 1 and 100
        rand_num = random.randint(0, 100)

        if rand_num < attack_level:
            counter = counter + 1
            print(f"Attack triggered: {rand_num} < {attack_level} ({counter})")
            apply_traffic_delay()
            time.sleep(2)  # Wait for 2 seconds before resetting
            reset_traffic_delay()
        else:
            time.sleep(2)


main()
