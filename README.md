# Actor System Benchmarks: Elixir vs Swift

This repository contains benchmark implementations comparing actor-based concurrency in Elixir and Swift using distributed actors.

## Implementations

- **[Elixir Benchmark](elixir-benchmark/)** - Uses Elixir processes and the BEAM virtual machine
- **[Swift Benchmark](swift-benchmark/)** - Uses Swift distributed actors with `swift-erlang-actor-system`

## Benchmark Results

Complete benchmark results are available in:
- **[Swift Results](swift_results_complete.txt)**
- **[Elixir Results](elixir_results.txt)**

### Actor/Process Creation Times

| Scale | Elixir | Swift |
|-------|--------|-------|
| 1,000 | 1.977ms | 20.61ms |
| 10,000 | 8.808ms | 186.94ms |
| 100,000 | 84.269ms | 2598.78ms |
| 1,000,000 | 1237.433ms | 27359.08ms |

### Actor/Process Creation Rates

| Scale | Elixir | Swift |
|-------|--------|-------|
| 1,000 | 505,816/sec | 48,529/sec |
| 10,000 | 1,135,331/sec | 53,493/sec |
| 100,000 | 1,186,676/sec | 38,479/sec |
| 1,000,000 | 808,124/sec | 36,550/sec |

### Message Processing Times

| Scale | Elixir | Swift |
|-------|--------|-------|
| 1,000 | 1.343ms | 1.55ms |
| 10,000 | 12.512ms | 15.79ms |
| 100,000 | 124.481ms | 174.32ms |
| 1,000,000 | 2257.976ms | 3280.91ms |

### Message Processing Rates

| Scale | Elixir | Swift |
|-------|--------|-------|
| 1,000 | 744,601/sec | 644,731/sec |
| 10,000 | 799,232/sec | 633,231/sec |
| 100,000 | 803,335/sec | 573,651/sec |
| 1,000,000 | 442,874/sec | 304,793/sec |

### Memory Usage

| Scale | Elixir | Swift |
|-------|--------|-------|
| 1,000 | 61.31 MB | 17.05 MB |
| 10,000 | 84.12 MB | 95.97 MB |
| 100,000 | 313.03 MB | 875.56 MB |
| 1,000,000 | 2588.64 MB | 2721.14 MB |

### Average Response Time per Message

| Scale | Elixir | Swift |
|-------|--------|-------|
| 1,000 | 0.001343ms | 0.0016ms |
| 10,000 | 0.0012512ms | 0.0016ms |
| 100,000 | 0.00124481ms | 0.0017ms |
| 1,000,000 | 0.002257976ms | 0.0033ms |

## Test Environment

- **Hardware**: Apple Silicon Mac
- **Swift**: Version 6.1.2, Release build (-c release)
- **Elixir**: BEAM virtual machine
- **Date**: June 12, 2025

## Running the Benchmarks

### Elixir
```bash
cd elixir-benchmark
mix run -e "ElixirBenchmark.scaling_test()"
```

### Swift
```bash
cd swift-benchmark
swift build -c release
swift run -c release swift-benchmark
```

## Architecture

Both implementations test:
- Actor/process creation at scale
- Message passing (ping/pong pattern)
- Memory usage tracking
- Concurrent computation capabilities

The Swift implementation uses the `swift-erlang-actor-system` library to enable interoperability with Erlang/Elixir systems while maintaining Swift's type safety and modern async/await syntax. 