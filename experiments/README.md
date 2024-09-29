# Reproducing Results

This directory contains instructions on how to reproduce the results detailed in our paper.

## Creating the Test Bed

Using the AWS console, create `N` VMs with the following specifications:

- **Instance Type:** `m5d.8xlarge`
- **AMI:** ` Ubuntu server 22.04`
- **Security Group:** Open all TCP ports.
- **Key Pair:** Use an existing key pair for all VMs.
- **AWS regions:** : us-east-2 ,us-west-2, af-south-1, ap-east-1, eu-south-1.

Next, update the relevant scripts in `experiments/aws/` to reflect the IPs of the newly created VMs:

- **For best case 50 nodes:** use `ip-best-50.sh`
- **For best case 10 nodes:** use `ip-best.sh`
- **For crash scenario:** use `ip-crash.sh`

## Setting Up the Test Bed

Run ```experiments/dedis-10/setup.sh```, using the appropriate IP script (`ip-x-x.sh`):

```bash
./experiments/dedis-10/setup.sh experiments/aws/[ip-best-50.sh|ip-best.sh|ip-crash.sh]
```

This command will set up Mahi-Mahi on `N` replicas (`N`=`50` or `10`)

## Running Mahi-Mahi

To run Mahi-Mahi, use the `experiments/python/run-all.py` script with the following arguments:

1. **bash_file:** One of the bash scripts from `experiments/dedis-10/`:
    - `remote_test.sh` for 10 nodes best case.
    - `remote-test-50.sh` for 50 nodes best case.
    - `remote-test-crash-3.sh` for 10 nodes crash case.

2. **input_csv:** One of the `.csv` files located in the `experiments/input_params/` folder.

3. **output_root:** `logs/dedis-10`.

4. **output_csv:** `results.csv`.

5. **num_replicas:** Specify the number of replicas:
    - `50` for the best case with 50 nodes.
    - `10` for the best case with 10 nodes.
    - `7` for the crash case with 10 nodes.

## Interpreting the Results

Once the above command is complete, a CSV file will be generated containing performance measurements of all **validators**.
The measurements will include:

- **Throughput** in units of transactions per second.
- **Latency** in **microseconds**.

You can use **MS Excel** or **Google Sheets** to analyze the results, and compute the average latency and throughput using standard macros.
