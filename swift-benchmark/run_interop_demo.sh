#!/bin/bash

echo "=== Actor System Interoperability Demo ==="
echo

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}1. Building Swift benchmark...${NC}"
swift build
if [ $? -ne 0 ]; then
    echo "Failed to build Swift benchmark"
    exit 1
fi

echo
echo -e "${BLUE}2. Running Swift distributed actor benchmark...${NC}"
echo -e "${YELLOW}This will create distributed actors that can interoperate with Elixir${NC}"
echo
swift run swift-benchmark

echo
echo -e "${BLUE}3. Running Elixir benchmark for comparison...${NC}"
echo -e "${YELLOW}Switching to Elixir implementation${NC}"
echo

cd ../elixir-benchmark

# Check if mix is available
if command -v mix &> /dev/null; then
    echo -e "${GREEN}Running Elixir benchmark...${NC}"
    mix run -e "ElixirBenchmark.run_benchmark(100_000); ElixirBenchmark.scaling_test()"
else
    echo -e "${YELLOW}Mix not available, running with elixir directly...${NC}"
    elixir -e "
    Code.require_file(\"lib/elixir_benchmark.ex\")
    
    ElixirBenchmark.run_benchmark(100_000)
    IO.puts(\"\")
    ElixirBenchmark.scaling_test()
    "
fi

echo
echo -e "${BLUE}=== Performance Comparison Summary ===${NC}"
echo
echo -e "${GREEN}Elixir Strengths:${NC}"
echo "• Can easily handle millions of lightweight processes"
echo "• Built-in fault tolerance and supervision"
echo "• Native distribution and clustering"
echo "• Hot code swapping capabilities"
echo "• Lower memory overhead per process"
echo

echo -e "${GREEN}Swift Strengths:${NC}"
echo "• Type-safe distributed function calls"
echo "• Modern async/await concurrency model"
echo "• Memory safety with ARC"
echo "• Native iOS/macOS integration"
echo "• Interoperability with Erlang/Elixir systems"
echo

echo -e "${BLUE}Interoperability Notes:${NC}"
echo "• Swift actors use @StableNames for cross-language compatibility"
echo "• Both can connect to the same Erlang distribution protocol"
echo "• Messages are encoded using Erlang's External Term Format"
echo "• Swift actors appear as GenServer processes to Elixir"
echo

echo -e "${YELLOW}To test interoperability:${NC}"
echo "1. Start IEx: iex --sname elixir_node --cookie benchmark_cookie"
echo "2. Run Swift benchmark with connection enabled"
echo "3. Call Swift actors from Elixir using GenServer.call/3"
echo

cd ../swift-benchmark 