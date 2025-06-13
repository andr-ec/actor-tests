defmodule ElixirBenchmark do
 @moduledoc """
  Simple benchmark demonstrating Elixir's ability to scale to millions of lightweight processes.
  Each process acts as an independent actor that can receive and respond to messages.
  """

  def run_benchmark(num_processes \\ 1_000_000) do
    IO.puts("Starting benchmark with #{format_number(num_processes)} processes...")
    
    # Measure process creation time
    {creation_time, pids} = :timer.tc(fn -> 
      spawn_processes(num_processes) 
    end)
    
    IO.puts("✓ Created #{format_number(num_processes)} processes in #{creation_time / 1000}ms")
    IO.puts("Memory usage: #{get_memory_usage()} MB")
    
    # Measure message passing
    {message_time, responses} = :timer.tc(fn ->
      send_messages_to_all(pids)
    end)
    
    IO.puts("✓ Sent and received #{format_number(length(responses))} messages in #{message_time / 1000}ms")
    IO.puts("Average response time per message: #{(message_time / length(responses)) / 1000}ms")
    
    # Clean up
    cleanup_processes(pids)
    IO.puts("✓ Cleaned up all processes")
    
    %{
      processes: num_processes,
      creation_time_ms: creation_time / 1000,
      message_time_ms: message_time / 1000,
      memory_mb: get_memory_usage()
    }
  end

  # Simple actor that responds to ping messages
  defp simple_actor do
    receive do
      {:ping, sender} ->
        send(sender, {:pong, self()})
        simple_actor()
      :stop ->
        :ok
    end
  end

  # Spawn the specified number of processes
  defp spawn_processes(count) do
    1..count
    |> Enum.map(fn _ -> spawn(fn -> simple_actor() end) end)
  end

  # Send a ping message to all processes and collect responses
  defp send_messages_to_all(pids) do
    parent = self()
    
    # Send ping to all processes
    Enum.each(pids, fn pid ->
      send(pid, {:ping, parent})
    end)
    
    # Collect all responses
    collect_responses(length(pids), [])
  end

  defp collect_responses(0, responses), do: responses
  defp collect_responses(count, responses) do
    receive do
      {:pong, _pid} ->
        collect_responses(count - 1, [count | responses])
    end
  end

  # Clean up all processes
  defp cleanup_processes(pids) do
    Enum.each(pids, fn pid ->
      if Process.alive?(pid) do
        send(pid, :stop)
      end
    end)
  end

  # Get current memory usage in MB
  defp get_memory_usage do
    :erlang.memory(:total) / (1024 * 1024) |> Float.round(2)
  end

  # Format large numbers with underscores for readability
  defp format_number(num) do
    num
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1_")
    |> String.reverse()
  end

  # Run a scaling test with different process counts
  def scaling_test do
    IO.puts("=== Elixir Actor Scaling Test ===\n")
    
    [1_000, 10_000, 100_000, 1_000_000]
    |> Enum.each(fn count ->
      IO.puts("--- Testing with #{format_number(count)} processes ---")
      result = run_benchmark(count)
      
      processes_per_second = count / (result.creation_time_ms / 1000)
      messages_per_second = count / (result.message_time_ms / 1000)
      
      IO.puts("Processes created per second: #{format_number(trunc(processes_per_second))}")
      IO.puts("Messages processed per second: #{format_number(trunc(messages_per_second))}")
      IO.puts("")
    end)
  end

  # Demonstrate concurrent computation with actors
  def concurrent_computation_demo(num_workers \\ 100_000) do
    IO.puts("=== Concurrent Computation Demo ===")
    IO.puts("Computing sum of squares using #{format_number(num_workers)} worker processes")
    
    range = 1..1_000_000
    chunk_size = div(Enum.count(range), num_workers)
    
    {time, result} = :timer.tc(fn ->
      range
      |> Enum.chunk_every(chunk_size)
      |> Enum.map(fn chunk ->
        spawn_link(fn ->
          sum = Enum.reduce(chunk, 0, fn n, acc -> acc + n * n end)
          send(self(), {:result, sum})
        end)
      end)
      |> Enum.map(fn _pid ->
        receive do
          {:result, sum} -> sum
        end
      end)
      |> Enum.sum()
    end)
    
    IO.puts("✓ Computed sum of squares: #{format_number(result)}")
    IO.puts("✓ Time taken: #{time / 1000}ms using #{format_number(num_workers)} processes")
  end
end
