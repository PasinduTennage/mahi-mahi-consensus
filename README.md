# Mahi-Mahi Asynchronous Consensus Protocol

Mahi-Mahi is a high-throughput asynchronous consensus protocol designed to provide efficient distributed consensus
with a low-latency approach. It achieves consensus in **4 network hops** and utilizes a **Directed Acyclic Graph (DAG)** structure,
offering superior performance in decentralized systems.

## Key Features:
- **4 Network Hops:** Asynchronous consensus mechanism with minimal communication overhead.
- **DAG-based Protocol:** Efficient management of concurrent requests, inspired by **codial-miners**.
- **High Throughput:** Capable of sustaining up to **350,000 requests per second** (512B request size).
- **Latency Improvement:** 20% reduction in latency compared to state-of-the-art protocols.

## Performance:
Mahi-Mahi offers significant improvements over existing consensus algorithms:
- **20% improvement in latency.**
- **350k req/s throughput** with a request size of 512B in the wide-area.

## Getting Started:
Instructions for setting up and running the experiments can be found in the **experiments** directory.
Follow the steps outlined there to evaluate Mahi-Mahi's performance in your environment.

## License

This software is licensed as [Apache 2.0](LICENSE).
