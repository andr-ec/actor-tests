# Swift Distributed Actor Benchmark

This Swift implementation mirrors the Elixir benchmark using the `swift-erlang-actor-system` library, demonstrating distributed actors that can interoperate with Erlang/Elixir systems.

## Benchmark Results

- **[Swift Results](swift_results_complete.txt)** - Complete benchmark results for Swift distributed actors
- **[Elixir Results](elixir_results.txt)** - Complete benchmark results for Elixir processes

Both benchmarks test actor/process creation, message passing, and scaling across different actor counts from 10 to 1,000,000.

## Overview

The benchmark demonstrates:
- **Distributed Actor Creation**: Creating thousands of distributed actors using Swift's actor system
- **Message Passing**: Sending ping/pong messages between actors
- **Scaling Tests**: Performance evaluation with varying actor counts
- **Concurrent Computation**: Parallel processing using distributed actors
- **Elixir Interoperability**: Actors that can communicate with Elixir processes

## Key Differences from Elixir

### Elixir Implementation
- Uses lightweight processes (millions possible)
- Direct message passing with `send/2` and `receive`
- Built on the BEAM virtual machine
- Preemptive scheduling and fault isolation

### Swift Implementation  
- Uses distributed actors with `ErlangActorSystem`
- Async/await message passing
- Compiled to native code
- Cooperative scheduling within actor boundaries

## Running the Benchmark

### Prerequisites
- Swift 6.0+
- macOS 15.0+
- Xcode command line tools

### Build and Run
```bash
# Build in release mode for optimal performance
swift build -c release

# Run the complete benchmark suite
swift run -c release swift-benchmark
```

### Benchmark Components

1. **Basic Benchmark**: Creates 10 actors and tests message passing
2. **Scaling Test**: Tests with 10, 50, 100, 1,000, 10,000, and 100,000 actors
3. **Million Actor Challenge**: Attempts to create and manage 1,000,000 actors
4. **Concurrent Computation**: Demonstrates parallel computation using distributed actors

## Architecture

```
SwiftBenchmark (main)
├── ActorBenchmark (coordinator)
├── PingPongActor (distributed actor)
├── ComputeWorker (distributed actor)
└── ErlangActorSystem (runtime)
```

## Features

### 1. Distributed Actors
```swift
@StableNames
distributed actor PingPongActor {
    typealias ActorSystem = ErlangActorSystem
    
    @StableName("ping")
    distributed func ping() -> String {
        return "pong"
    }
}
```

### 2. Concurrent Actor Creation
```swift
let actors = try await withThrowingTaskGroup(of: PingPongActor.self) { group in
    for i in 0..<count {
        group.addTask {
            return await PingPongActor(id: i, actorSystem: actorSystem)
        }
    }
    // Collect all actors...
}
```

### 3. Parallel Message Passing
```swift
let responses = try await withThrowingTaskGroup(of: String.self) { group in
    for actor in actors {
        group.addTask {
            return try await actor.ping()
        }
    }
    // Collect all responses...
}
```

## Running the Benchmark

```bash
# Build the project
swift build

# Run the benchmark
swift run swift-benchmark
```

## Sample Output

```
=== Swift Distributed Actor Benchmark ===

Starting benchmark with 100,000 actors...
✓ Created 100,000 actors in 1,234.56ms
Memory usage: 45.67 MB
✓ Sent and received 100,000 messages in 567.89ms
Average response time per message: 0.0057ms
Actors created per second: 81,037
Messages processed per second: 176,211

=== Scaling Test ===

--- Testing with 1,000 actors ---
...

=== Concurrent Computation Demo ===
Computing sum of squares using 100 worker actors
✓ Computed sum of squares: 333,333,833,333,500,000
✓ Time taken: 123.45ms using 100 actors
```

## Interoperability with Elixir

This Swift implementation can connect to and communicate with Elixir nodes:

### 1. Start an Elixir node
```elixir
# Start IEx as a distributed node
iex --sname elixir_node --cookie benchmark_cookie
```

### 2. Connect from Swift
```swift
let actorSystem = try ErlangActorSystem(
    name: "swift_benchmark", 
    cookie: "benchmark_cookie"
)
try await actorSystem.connect(to: "elixir_node@hostname")
```

### 3. Call Swift actors from Elixir
```elixir
# Register a Swift actor in Elixir
GenServer.call({:ping_actor, :"swift_benchmark@hostname"}, :ping)
# Returns: "pong"
```

## Performance Considerations

### Swift Advantages
- **Type Safety**: Compile-time type checking for distributed calls
- **Memory Safety**: Automatic memory management with ARC
- **Integration**: Native iOS/macOS integration when needed
- **Async/Await**: Modern concurrency model

### Elixir Advantages
- **Scale**: Can handle millions of lightweight processes
- **Fault Tolerance**: Built-in supervision and restart mechanisms
- **Hot Code Swapping**: Update code without stopping the system
- **Distribution**: Designed from ground up for distributed systems

## Dependencies

- **swift-erlang-actor-system**: Provides the distributed actor runtime
- **Swift 5.9+**: Required for distributed actor support
- **macOS 13+**: Platform requirement for the actor system

## Limitations

- **Scale**: Swift actors have more overhead than Elixir processes
- **Distribution**: Requires more setup than native Elixir clustering
- **Debugging**: Less mature tooling compared to Elixir/OTP

This benchmark demonstrates that while Swift can implement actor-based concurrency and interoperate with Erlang/Elixir systems, each language has its strengths for different use cases.

## Files

- `Package.swift` - Swift package configuration with dependencies
- `Sources/swift-benchmark/swift_benchmark.swift` - Main benchmark implementation
- `swift_results_complete.txt` - Latest Swift benchmark results
- `elixir_results.txt` - Latest Elixir benchmark results for comparison
