# Reproducing Results

This directory contains instructions on how to reproduce the results detailed in our paper.

## Creating the Test Bed

To create a test bed of `N` nodes, use the following command:

```bash
cargo run --bin orchestrator -- testbed deploy --instances N/5
```

_(Assuming you want to run in 5 AWS regions.)_

For more details on running the orchestrator, refer to the *orchestrator README*.

Next, update the relevant scripts in `experiments/aws/` to reflect the IPs of the newly created VMs:

- **For best case 50 nodes:** use `ip-best-50.sh`
- **For best case 10 nodes:** use `ip-best.sh`
- **For crash scenario:** use `ip-crash.sh`

## Setting Up the Test Bed

Run the following setup script, using the appropriate IP script (`ip-x-x.sh`):

```bash
./experiments/dedis-10/setup.sh experiments/aws/ip-x-x.sh
```

This command will set up Mahi-Mahi on `N` replicas.

## Running Mahi-Mahi

To run Mahi-Mahi, use the `experiments/python/run-all.py` script with the following arguments:

1. **bash_file:** One of the bash scripts from `experiments/dedis-10/`:
    - `remote_test.sh` for 10 best case nodes.
    - `remote-test-50.sh` for 50 best case nodes.
    - `remote-test-crash-3.sh` for crash case.

2. **input_csv:** One of the `.csv` files located in the `experiments/input_params/` folder.

3. **output_root:** Specify the output root directory, for example `logs/dedis-10`.

4. **output_csv:** Provide the preferred CSV file name for the output.

5. **num_replicas:** Specify the number of replicas:
    - `50` for the best case with 50 nodes.
    - `10` for the best case with 10 nodes.
    - `7` for the crash case with 10 nodes.

## Interpreting the Results

Once the above command is complete, a CSV file will be generated containing performance measurements from all **replicas**. The measurements will include:

- **Throughput** in units of requests per second.
- **Latency** in microseconds.

You can use **MS Excel** or **Google Sheets** to analyze the results, and compute the average latency and throughput using standard macros.
