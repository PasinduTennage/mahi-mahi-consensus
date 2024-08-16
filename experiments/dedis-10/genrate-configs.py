import os
import yaml
import argparse

# Set up command-line argument parsing
parser = argparse.ArgumentParser(description='Generate node-parameters.yml and client-parameters.yml files.')

parser.add_argument('--wave_length', type=int, default=5, help='Wave length (default: 5)')
parser.add_argument('--number_of_leaders', type=int, default=3, help='Number of leaders (default: 3)')
parser.add_argument('--enable_pipelining', type=str, default="True", help='Enable pipelining (default: True)')
parser.add_argument('--consensus_only', type=str, default="True", help='Consensus only (default: True)')
parser.add_argument('--enable_synchronizer', type=str, default="False", help='Enable synchronizer (default: False)')
parser.add_argument('--initial_delay_secs', type=int, default=1, help='Initial delay in seconds (default: 1)')
parser.add_argument('--initial_delay_nanos', type=int, default=500, help='Initial delay in nanoseconds (default: 500)')
parser.add_argument('--load', type=int, default=100000, help='Load (default: 100000)')
parser.add_argument('--transaction_size', type=int, default=512, help='Transaction size (default: 512)')
parser.add_argument('--output_dir', type=str, default="logs/dedis-10/", help='configuration file output directory')

args = parser.parse_args()

# File 1: node-parameters.yml
node_parameters = {
    'leader_timeout': {
        'secs': 0,
        'nanos': 0
    },
    'wave_length': args.wave_length,
    'number_of_leaders': args.number_of_leaders,
    'enable_pipelining': args.enable_pipelining,
    'consensus_only': args.consensus_only,
    'enable_synchronizer': args.enable_synchronizer
}

# Write node-parameters.yml
with open(os.path.join(args.output_dir, 'node-parameters.yml'), 'w') as file:
    yaml.dump(node_parameters, file, default_flow_style=False)

# File 2: client-parameters.yml
client_parameters = {
    'initial_delay': {
        'secs': args.initial_delay_secs,
        'nanos': args.initial_delay_nanos
    },
    'load': args.load,
    'transaction_size': args.transaction_size
}

# Write client-parameters.yml
with open(os.path.join(args.output_dir, 'client-parameters.yml'), 'w') as file:
    yaml.dump(client_parameters, file, default_flow_style=False)

print(f"Files generated in {args.output_dir}:")
print("- node-parameters.yml")
print("- client-parameters.yml")
