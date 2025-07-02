defmodule ExNylas.Paging.HelpersTest do
  use ExUnit.Case, async: true

  alias ExNylas.Paging.Helpers

  describe "maybe_delay/1" do
    test "does not delay when delay is 0" do
      start_time = System.monotonic_time(:millisecond)
      Helpers.maybe_delay(0)
      end_time = System.monotonic_time(:millisecond)

      assert end_time - start_time < 50
    end

    test "does not delay when delay is negative" do
      start_time = System.monotonic_time(:millisecond)
      Helpers.maybe_delay(-100)
      end_time = System.monotonic_time(:millisecond)

      # Should be very fast, but allow some system overhead
      assert end_time - start_time < 50
    end

    test "delays when delay is positive" do
      delay_ms = 10
      start_time = System.monotonic_time(:millisecond)
      Helpers.maybe_delay(delay_ms)
      end_time = System.monotonic_time(:millisecond)

      assert end_time - start_time >= delay_ms
    end
  end

  describe "send_or_accumulate/4" do
    test "accumulates data when send_to is nil" do
      acc = [1, 2]
      data = [3, 4]

      result = Helpers.send_or_accumulate(nil, nil, acc, data)
      assert result == [1, 2, 3, 4]
    end

    test "sends data to function when send_to is provided without metadata" do
      acc = [1, 2]
      data = [3, 4]
      received = []

      send_to_fn = fn d ->
        send(self(), {:received, d})
        received
      end

      result = Helpers.send_or_accumulate(send_to_fn, nil, acc, data)
      assert result == [1, 2]
      assert_receive {:received, [3, 4]}
    end

    test "sends data with metadata when both send_to and with_metadata are provided" do
      acc = [1, 2]
      data = [3, 4]
      metadata = :test_metadata

      send_to_fn = fn {meta, d} ->
        send(self(), {:received, meta, d})
        acc
      end

      result = Helpers.send_or_accumulate(send_to_fn, metadata, acc, data)
      assert result == [1, 2]
      assert_receive {:received, :test_metadata, [3, 4]}
    end
  end
end
