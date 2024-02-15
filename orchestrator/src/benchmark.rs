// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

use std::{
    fmt::{Debug, Display},
    time::Duration,
};

use serde::{de::DeserializeOwned, Deserialize, Serialize};

use crate::{faults::FaultsType, ClientConfig, NodeConfig};

pub trait Config: Default + Clone + Serialize + DeserializeOwned + Debug + Display {}

pub type BenchmarkParameters = BenchmarkParametersGeneric<NodeConfig, ClientConfig>;

/// The benchmark parameters for a run.
#[derive(Serialize, Deserialize, Clone)]
pub struct BenchmarkParametersGeneric<N, C> {
    /// The node's configuration parameters.
    pub node_config: N,
    /// The client's configuration parameters.
    pub client_config: C,
    /// The committee size.
    pub nodes: usize,
    /// The number of (crash-)faults.
    pub faults: FaultsType,
    /// The total load (tx/s) to submit to the system.
    pub load: usize,
    /// The duration of the benchmark.
    pub duration: Duration,
}

impl<N: Default, C: Default> Default for BenchmarkParametersGeneric<N, C> {
    fn default() -> Self {
        Self {
            node_config: N::default(),
            client_config: C::default(),
            nodes: 4,
            faults: FaultsType::default(),
            load: 500,
            duration: Duration::from_secs(60),
        }
    }
}

impl<N: Debug, C> Debug for BenchmarkParametersGeneric<N, C> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{:?}-{:?}-{}-{}",
            self.node_config, self.faults, self.nodes, self.load
        )
    }
}

impl<N, C> Display for BenchmarkParametersGeneric<N, C> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{} nodes ({}) - {} tx/s",
            self.nodes, self.faults, self.load
        )
    }
}

// Requiring `N` and `C` to be `Config` is not necessary, but clarifies error messages if the user forgets to
// implement the `Config` trait for `N` and `C`.
impl<N: Config, C: Config> BenchmarkParametersGeneric<N, C> {
    /// Make a new benchmark parameters.
    pub fn new_from_loads(
        node_config: N,
        client_config: C,
        nodes: usize,
        faults: FaultsType,
        loads: Vec<usize>,
        duration: Duration,
    ) -> Vec<Self> {
        loads
            .into_iter()
            .map(|load| Self {
                node_config: node_config.clone(),
                client_config: client_config.clone(),
                nodes,
                faults: faults.clone(),
                load,
                duration,
            })
            .collect()
    }
}

// /// The load type to submit to the nodes.
// pub enum LoadType {
//     /// Submit a fixed set of loads (one per benchmark run).
//     Fixed(Vec<usize>),

//     /// Search for the breaking point of the L-graph.
//     // TODO: Doesn't work very well, use tps regression as additional signal.
//     #[allow(dead_code)]
//     Search {
//         /// The initial load to test (and use a baseline).
//         starting_load: usize,
//         /// The maximum number of iterations before converging on a breaking point.
//         max_iterations: usize,
//     },
// }

// /// Generate benchmark parameters (one set of parameters per run).
// pub struct BenchmarkParametersGenerator<N, C> {
//     /// The node's configuration parameters.
//     node_config: N,
//     /// The client's configuration parameters.
//     client_config: C,
//     /// The committee size.
//     pub nodes: usize,
//     /// The load type.
//     load_type: LoadType,
//     /// The number of faulty nodes.
//     pub faults: FaultsType,
//     /// The duration of the benchmark.
//     duration: Duration,
//     /// The load of the next benchmark run.
//     next_load: Option<usize>,
//     /// Temporary hold a lower bound of the breaking point.
//     lower_bound_result: Option<MeasurementsCollection<T>>,
//     /// Temporary hold an upper bound of the breaking point.
//     upper_bound_result: Option<MeasurementsCollection<T>>,
//     /// The current number of iterations.
//     iterations: usize,
// }

// impl<N: Clone, C: Clone> Iterator for BenchmarkParametersGenerator<N, C> {
//     type Item = BenchmarkParameters<N, C>;

//     /// Return the next set of benchmark parameters to run.
//     fn next(&mut self) -> Option<Self::Item> {
//         self.next_load.map(|load| {
//             BenchmarkParameters::new(
//                 self.node_config.clone(),
//                 self.nodes,
//                 self.faults.clone(),
//                 load,
//                 self.duration,
//             )
//         })
//     }
// }

// impl<T: NodeConfig> BenchmarkParametersGenerator<T> {
//     /// The default benchmark duration.
//     const DEFAULT_DURATION: Duration = Duration::from_secs(180);

//     /// make a new generator.
//     pub fn new(nodes: usize, mut load_type: LoadType) -> Self {
//         let next_load = match &mut load_type {
//             LoadType::Fixed(loads) => {
//                 if loads.is_empty() {
//                     None
//                 } else {
//                     Some(loads.remove(0))
//                 }
//             }
//             LoadType::Search { starting_load, .. } => Some(*starting_load),
//         };
//         Self {
//             node_config: T::default(),
//             nodes,
//             load_type,
//             faults: FaultsType::default(),
//             duration: Self::DEFAULT_DURATION,
//             next_load,
//             lower_bound_result: None,
//             upper_bound_result: None,
//             iterations: 0,
//         }
//     }

//     /// Set the benchmark type.
//     pub fn with_node_config(mut self, node_config: T) -> Self {
//         self.node_config = node_config;
//         self
//     }

//     /// Set crash-recovery pattern and the number of faulty nodes.
//     pub fn with_faults(mut self, faults: FaultsType) -> Self {
//         self.faults = faults;
//         self
//     }

//     /// Set a custom benchmark duration.
//     pub fn with_custom_duration(mut self, duration: Duration) -> Self {
//         self.duration = duration;
//         self
//     }

//     /// Detects whether the latest benchmark parameters run the system out of capacity.
//     fn out_of_capacity(
//         last_result: &MeasurementsCollection<T>,
//         new_result: &MeasurementsCollection<T>,
//     ) -> bool {
//         let Some(first_label) = new_result.labels().next() else {
//             return false;
//         };

//         // We consider the system is out of capacity if the latency increased by over 5x with
//         // respect to the latest run.
//         let threshold = last_result.aggregate_average_latency(first_label) * 5;
//         let high_latency = new_result.aggregate_average_latency(first_label) > threshold;

//         // Or if the throughput is less than 2/3 of the input rate.
//         let last_load = new_result.transaction_load() as u64;
//         let no_throughput_increase = new_result.aggregate_tps(first_label) < (2 * last_load / 3);

//         high_latency || no_throughput_increase
//     }

//     /// Register a new benchmark measurements collection. These results are used to determine
//     /// whether the system reached its breaking point.
//     pub fn register_result(&mut self, result: MeasurementsCollection<T>) {
//         self.next_load = match &mut self.load_type {
//             LoadType::Fixed(loads) => {
//                 if loads.is_empty() {
//                     None
//                 } else {
//                     Some(loads.remove(0))
//                 }
//             }
//             LoadType::Search { max_iterations, .. } => {
//                 // Terminate the the search.
//                 if self.iterations >= *max_iterations {
//                     None

//                 // Search for the breaking point.
//                 } else {
//                     self.iterations += 1;
//                     match (&mut self.lower_bound_result, &mut self.upper_bound_result) {
//                         (None, None) => {
//                             let next = result.transaction_load() * 2;
//                             self.lower_bound_result = Some(result);
//                             Some(next)
//                         }
//                         (Some(lower), None) => {
//                             if Self::out_of_capacity(lower, &result) {
//                                 let next =
//                                     (lower.transaction_load() + result.transaction_load()) / 2;
//                                 self.upper_bound_result = Some(result);
//                                 Some(next)
//                             } else {
//                                 let next = result.transaction_load() * 2;
//                                 *lower = result;
//                                 Some(next)
//                             }
//                         }
//                         (Some(lower), Some(upper)) => {
//                             if Self::out_of_capacity(lower, &result) {
//                                 *upper = result;
//                             } else {
//                                 *lower = result;
//                             }
//                             Some((lower.transaction_load() + upper.transaction_load()) / 2)
//                         }
//                         _ => panic!("Benchmark parameters generator is in an incoherent state"),
//                     }
//                 }
//             }
//         };
//     }
// }

#[cfg(test)]
pub mod test {
    use std::{fmt::Display, str::FromStr};

    use serde::{Deserialize, Serialize};

    // use crate::{
    //     measurement::{Measurement, MeasurementsCollection},
    //     settings::Settings,
    // };

    use super::Config;

    /// Mock benchmark type for unit tests.
    #[derive(
        Serialize, Deserialize, Debug, Clone, PartialEq, PartialOrd, Eq, Ord, Hash, Default,
    )]
    pub struct TestNodeConfig;

    impl Display for TestNodeConfig {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "TestNodeConfig")
        }
    }

    impl FromStr for TestNodeConfig {
        type Err = ();

        fn from_str(_s: &str) -> Result<Self, Self::Err> {
            Ok(Self {})
        }
    }

    impl Config for TestNodeConfig {}

    //     #[test]
    //     fn set_lower_bound() {
    //         let settings = Settings::new_for_test();
    //         let nodes = 4;
    //         let load = LoadType::Search {
    //             starting_load: 100,
    //             max_iterations: 10,
    //         };
    //         let mut generator = BenchmarkParametersGenerator::<TestNodeConfig>::new(nodes, load);
    //         let parameters = generator.next().unwrap();

    //         let collection = MeasurementsCollection::new(&settings, parameters);
    //         generator.register_result(collection);

    //         let next_parameters = generator.next();
    //         assert!(next_parameters.is_some());
    //         assert_eq!(next_parameters.unwrap().load, 200);

    //         assert!(generator.lower_bound_result.is_some());
    //         assert_eq!(
    //             generator.lower_bound_result.unwrap().transaction_load(),
    //             100
    //         );
    //         assert!(generator.upper_bound_result.is_none());
    //     }

    //     #[test]
    //     fn set_upper_bound() {
    //         let settings = Settings::new_for_test();
    //         let nodes = 4;
    //         let load = LoadType::Search {
    //             starting_load: 100,
    //             max_iterations: 10,
    //         };
    //         let mut generator = BenchmarkParametersGenerator::<TestNodeConfig>::new(nodes, load);
    //         let first_parameters = generator.next().unwrap();

    //         // Register a first result (zero latency). This sets the lower bound.
    //         let collection = MeasurementsCollection::new(&settings, first_parameters);
    //         generator.register_result(collection);
    //         let second_parameters = generator.next().unwrap();

    //         // Register a second result (with positive latency). This sets the upper bound.
    //         let mut collection = MeasurementsCollection::new(&settings, second_parameters);
    //         let (label, measurement) = Measurement::new_for_test();
    //         collection.add(1, label, measurement);
    //         generator.register_result(collection);

    //         // Ensure the next load is between the upper and the lower bound.
    //         let third_parameters = generator.next();
    //         assert!(third_parameters.is_some());
    //         assert_eq!(third_parameters.unwrap().load, 150);

    //         assert!(generator.lower_bound_result.is_some());
    //         assert_eq!(
    //             generator.lower_bound_result.unwrap().transaction_load(),
    //             100
    //         );
    //         assert!(generator.upper_bound_result.is_some());
    //         assert_eq!(
    //             generator.upper_bound_result.unwrap().transaction_load(),
    //             200
    //         );
    //     }

    //     #[test]
    //     fn max_iterations() {
    //         let settings = Settings::new_for_test();
    //         let nodes = 4;
    //         let load = LoadType::Search {
    //             starting_load: 100,
    //             max_iterations: 0,
    //         };
    //         let mut generator = BenchmarkParametersGenerator::<TestNodeConfig>::new(nodes, load);
    //         let parameters = generator.next().unwrap();

    //         let collection = MeasurementsCollection::new(&settings, parameters);
    //         generator.register_result(collection);

    //         let next_parameters = generator.next();
    //         assert!(next_parameters.is_none());
    //     }
}
