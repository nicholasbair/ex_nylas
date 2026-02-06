defmodule ExNylas.TransportErrorTest do
  use ExUnit.Case, async: true
  alias ExNylas.TransportError

  describe "exception/1 with atom input" do
    test "creates exception for timeout" do
      error = TransportError.exception(:timeout)

      assert error.message == "Transport failed: request timed out"
      assert error.reason == :timeout
    end

    test "creates exception for connection refused" do
      error = TransportError.exception(:econnrefused)

      assert error.message == "Transport failed: connection refused"
      assert error.reason == :econnrefused
    end

    test "creates exception for DNS failure" do
      error = TransportError.exception(:nxdomain)

      assert error.message == "Transport failed: domain name not found"
      assert error.reason == :nxdomain
    end

    test "creates exception for closed connection" do
      error = TransportError.exception(:closed)

      assert error.message == "Transport failed: connection closed"
      assert error.reason == :closed
    end

    test "creates exception for network unreachable" do
      error = TransportError.exception(:enetunreach)

      assert error.message == "Transport failed: network unreachable"
      assert error.reason == :enetunreach
    end

    test "creates exception for host unreachable" do
      error = TransportError.exception(:ehostunreach)

      assert error.message == "Transport failed: host unreachable"
      assert error.reason == :ehostunreach
    end

    test "creates exception for connection reset" do
      error = TransportError.exception(:econnreset)

      assert error.message == "Transport failed: connection reset"
      assert error.reason == :econnreset
    end

    test "creates exception for broken pipe" do
      error = TransportError.exception(:epipe)

      assert error.message == "Transport failed: broken pipe"
      assert error.reason == :epipe
    end

    test "creates exception for unknown reason" do
      error = TransportError.exception(:custom_error)

      assert error.message == "Transport failed: :custom_error"
      assert error.reason == :custom_error
    end

    test "can be raised with atom" do
      assert_raise TransportError, "Transport failed: request timed out", fn ->
        raise TransportError, :timeout
      end
    end
  end

  describe "exception/1 with binary input" do
    test "creates exception from custom message" do
      error = TransportError.exception("Network connection lost")

      assert error.message == "Network connection lost"
      assert error.reason == :unknown
    end

    test "can be raised with binary" do
      assert_raise TransportError, "Custom transport error", fn ->
        raise TransportError, "Custom transport error"
      end
    end
  end

  describe "exception/1 with keyword list input" do
    test "creates exception from keyword list with all fields" do
      error = TransportError.exception(
        reason: :timeout,
        message: "Request timed out after 30s"
      )

      assert error.message == "Request timed out after 30s"
      assert error.reason == :timeout
    end

    test "creates exception from keyword list with only reason" do
      error = TransportError.exception(reason: :econnrefused)

      assert error.message == "Transport failed: connection refused"
      assert error.reason == :econnrefused
    end

    test "creates exception from keyword list with only message" do
      error = TransportError.exception(message: "Custom error")

      assert error.message == "Custom error"
      assert error.reason == :unknown
    end

    test "can be raised with keyword list" do
      assert_raise TransportError, "Timeout error", fn ->
        raise TransportError, [reason: :timeout, message: "Timeout error"]
      end
    end
  end

  describe "exception/1 with map input (atom keys)" do
    test "creates exception from map with all fields" do
      error = TransportError.exception(%{
        reason: :closed,
        message: "Connection was closed unexpectedly"
      })

      assert error.message == "Connection was closed unexpectedly"
      assert error.reason == :closed
    end

    test "creates exception from map with only reason" do
      error = TransportError.exception(%{reason: :nxdomain})

      assert error.message == "Transport failed: domain name not found"
      assert error.reason == :nxdomain
    end

    test "creates exception from map with only message" do
      error = TransportError.exception(%{message: "Network failure"})

      assert error.message == "Network failure"
      assert error.reason == :unknown
    end

    test "creates exception from empty map" do
      error = TransportError.exception(%{})

      assert error.message == "Transport failed: :unknown"
      assert error.reason == :unknown
    end
  end

  describe "exception/1 with map input (string keys)" do
    test "creates exception from map with string keys" do
      error = TransportError.exception(%{
        "reason" => :timeout,
        "message" => "Request timeout"
      })

      assert error.message == "Request timeout"
      assert error.reason == :timeout
    end

    test "creates exception from string key map with only reason" do
      error = TransportError.exception(%{"reason" => :econnreset})

      assert error.message == "Transport failed: connection reset"
      assert error.reason == :econnreset
    end
  end

  describe "exception/1 with struct input" do
    test "creates exception from existing error struct" do
      original = %TransportError{
        message: "Original error",
        reason: :timeout
      }

      error = TransportError.exception(original)

      assert error.message == "Original error"
      assert error.reason == :timeout
    end

    test "generates message if nil" do
      original = %TransportError{
        message: nil,
        reason: :closed
      }

      error = TransportError.exception(original)

      assert error.message == "Transport failed: connection closed"
      assert error.reason == :closed
    end
  end

  describe "message/1 callback" do
    test "returns the error message" do
      error = %TransportError{message: "Connection error", reason: :timeout}

      assert Exception.message(error) == "Connection error"
    end

    test "returns default message when nil" do
      error = %TransportError{message: nil, reason: :timeout}

      assert Exception.message(error) == "Transport failed"
    end
  end

  describe "integration with raise/rescue" do
    test "can pattern match on reason in rescue" do
      try do
        raise TransportError, :timeout
      rescue
        e in TransportError ->
          assert e.reason == :timeout
          assert e.message =~ "timed out"
      end
    end

    test "preserves all fields through raise/rescue" do
      try do
        raise TransportError, %{
          reason: :econnrefused,
          message: "Could not connect to server"
        }
      rescue
        e in TransportError ->
          assert e.reason == :econnrefused
          assert e.message == "Could not connect to server"
      end
    end
  end

  describe "exception type verification" do
    test "is an exception" do
      error = TransportError.exception(:timeout)

      assert Exception.exception?(error)
    end

    test "implements Exception behavior" do
      behaviours =
        TransportError.__info__(:attributes)
        |> Keyword.get_values(:behaviour)
        |> List.flatten()

      assert Exception in behaviours
    end
  end
end
