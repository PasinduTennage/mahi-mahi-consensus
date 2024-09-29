# Mahi-Mahi Asynchronous Consensus Protocol

Mahi-Mahi is a high-throughput asynchronous consensus protocol 
designed to provide efficient and scalable distributed consensus
with low-latency. 
It achieves consensus in **4 network hops** and utilizes 
a **Directed Acyclic Graph (DAG)** structure,
offering superior performance in decentralized systems.

## Key Features:
- **4 Network Hops:** Asynchronous consensus mechanism with minimal communication overhead.
- **DAG-based Protocol:** Efficient management of concurrent requests.
- **High Throughput:** Capable of sustaining up to **350,000 requests per second** (512B request size).
- **Latency Improvement:** upto 40% reduction in latency compared to state-of-the-art protocols.

## Performance:
Mahi-Mahi offers significant improvements over existing consensus algorithms:
- **upto 40%** improvement in latency.
- **350k req/s throughput** with a request size of 512B with 50 validators in the wide-area.

## Getting Started:

To run Mahi-Mahi in a single machine: 
```/bin/bash scripts/dryrun.sh```


Instructions for setting up and running the experiments in a distributed setup
can be found in the **experiments** directory.

## License
This software is licensed as [Apache 2.0](LICENSE).
