import Distributed
import ErlangActorSystem
import Foundation

/// Simple benchmark demonstrating Swift's distributed actors with ErlangActorSystem.
/// Each actor acts as an independent distributed actor that can receive and respond to messages,
/// similar to Elixir processes but using Swift's distributed actor system.
@main
public struct SwiftBenchmark {
    public static func main() async {
        do {
            let benchmark = ActorBenchmark()

            print("=== Swift Distributed Actor Benchmark ===\n")

            // Run the main benchmark
            try await benchmark.runBenchmark()

            print("\n=== Scaling Test ===")
            try await benchmark.scalingTest()

            print("\n=== Million Actor Challenge ===")
            print("Attempting to create 1,000,000 actors...")
            do {
                try await benchmark.runBenchmark(numActors: 1_000_000)
            } catch {
                print("❌ Failed to create 1M actors: \(error)")
            }

            print("\n=== Concurrent Computation Demo ===")
            try await benchmark.concurrentComputationDemo()

        } catch {
            print("Benchmark failed with error: \(error)")
        }
    }
}

/// Simple ping-pong distributed actor that responds to ping messages
@StableNames
distributed actor PingPongActor {
    typealias ActorSystem = ErlangActorSystem

    private let actorIndex: Int

    init(actorIndex: Int, actorSystem: ErlangActorSystem) async {
        self.actorIndex = actorIndex
        self.actorSystem = actorSystem
    }

    @StableName("ping")
    distributed func ping() -> String {
        return "pong"
    }

    @StableName("get_index")
    distributed func getIndex() -> Int {
        return actorIndex
    }
}

/// Worker actor for concurrent computation
@StableNames
distributed actor ComputeWorker {
    typealias ActorSystem = ErlangActorSystem

    init(actorSystem: ErlangActorSystem) async {
        self.actorSystem = actorSystem
    }

    @StableName("compute_sum_of_squares")
    distributed func computeSumOfSquares(_ numbers: [Int]) -> Int {
        return numbers.reduce(0) { acc, n in acc + n * n }
    }
}

/// Main benchmark coordinator
public class ActorBenchmark {
    private var actorSystem: ErlangActorSystem?

    public init() {}

    /// Run the main benchmark with a specified number of actors
    public func runBenchmark(numActors: Int = 10) async throws {
        // Create actor system
        actorSystem = try await ErlangActorSystem(
            name: "swift_benchmark", cookie: "benchmark_cookie")
        guard let actorSystem = actorSystem else {
            throw BenchmarkError.actorSystemCreationFailed
        }

        print("Starting benchmark with \(formatNumber(numActors)) actors...")

        // Measure actor creation time
        let creationStart = CFAbsoluteTimeGetCurrent()
        let actors = try await createActors(count: numActors, actorSystem: actorSystem)
        let creationTime = (CFAbsoluteTimeGetCurrent() - creationStart) * 1000

        print(
            "✓ Created \(formatNumber(numActors)) actors in \(String(format: "%.2f", creationTime))ms"
        )
        print("Memory usage: \(getMemoryUsage()) MB")

        // Measure message passing
        let messageStart = CFAbsoluteTimeGetCurrent()
        let responses = try await sendMessagesToAll(actors)
        let messageTime = (CFAbsoluteTimeGetCurrent() - messageStart) * 1000

        print(
            "✓ Sent and received \(formatNumber(responses.count)) messages in \(String(format: "%.2f", messageTime))ms"
        )
        print(
            "Average response time per message: \(String(format: "%.4f", messageTime / Double(responses.count)))ms"
        )

        // Calculate throughput
        let actorsPerSecond = Double(numActors) / (creationTime / 1000)
        let messagesPerSecond = Double(responses.count) / (messageTime / 1000)

        print("Actors created per second: \(formatNumber(Int(actorsPerSecond)))")
        print("Messages processed per second: \(formatNumber(Int(messagesPerSecond)))")
    }

    /// Create the specified number of distributed actors
    private func createActors(count: Int, actorSystem: ErlangActorSystem) async throws
        -> [PingPongActor]
    {
        var actors: [PingPongActor] = []

        // Create actors sequentially to avoid concurrency issues
        for i in 0..<count {
            let actor = await PingPongActor(actorIndex: i, actorSystem: actorSystem)
            actors.append(actor)
        }

        return actors
    }

    /// Send ping messages to all actors and collect responses
    private func sendMessagesToAll(_ actors: [PingPongActor]) async throws -> [String] {
        return try await withThrowingTaskGroup(of: String.self) { group in
            for actor in actors {
                group.addTask {
                    return try await actor.ping()
                }
            }

            var responses: [String] = []
            for try await response in group {
                responses.append(response)
            }
            return responses
        }
    }

    /// Run scaling tests with different actor counts
    public func scalingTest() async throws {
        let testCounts = [10, 50, 100, 1_000, 10_000, 100_000]

        for count in testCounts {
            print("\n--- Testing with \(formatNumber(count)) actors ---")
            try await runBenchmark(numActors: count)
        }
    }

    /// Demonstrate concurrent computation with distributed actors
    public func concurrentComputationDemo(numWorkers: Int = 10) async throws {
        if actorSystem == nil {
            self.actorSystem = try await ErlangActorSystem(
                name: "swift_compute", cookie: "compute_cookie")
        }

        guard let actorSystem = self.actorSystem else {
            throw BenchmarkError.actorSystemCreationFailed
        }

        print("Computing sum of squares using \(formatNumber(numWorkers)) worker actors")

        let range = Array(1...1_000)  // Reduced size for better performance
        let chunkSize = range.count / numWorkers

        let computeStart = CFAbsoluteTimeGetCurrent()

        // Create compute workers sequentially
        var workers: [ComputeWorker] = []
        for _ in 0..<numWorkers {
            let worker = await ComputeWorker(actorSystem: actorSystem)
            workers.append(worker)
        }

        // Distribute work and compute results
        let result = try await withThrowingTaskGroup(of: Int.self) { group in
            for (index, worker) in workers.enumerated() {
                group.addTask {
                    let startIdx = index * chunkSize
                    let endIdx = min(startIdx + chunkSize, range.count)
                    let chunk = Array(range[startIdx..<endIdx])
                    return try await worker.computeSumOfSquares(chunk)
                }
            }

            var totalSum = 0
            for try await partialSum in group {
                totalSum += partialSum
            }
            return totalSum
        }

        let computeTime = (CFAbsoluteTimeGetCurrent() - computeStart) * 1000

        print("✓ Computed sum of squares: \(formatNumber(result))")
        print(
            "✓ Time taken: \(String(format: "%.2f", computeTime))ms using \(formatNumber(numWorkers)) actors"
        )
    }

    /// Format large numbers with underscores for readability
    private func formatNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }

    /// Get current memory usage in MB
    private func getMemoryUsage() -> String {
        let task = mach_task_self_
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(task, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let memoryMB = Double(info.resident_size) / (1024 * 1024)
            return String(format: "%.2f", memoryMB)
        } else {
            return "N/A"
        }
    }
}

/// Benchmark-specific errors
enum BenchmarkError: Error {
    case actorSystemCreationFailed
}
