defmodule ExNylas.DecodeErrorTest do
  use ExUnit.Case, async: true
  alias ExNylas.DecodeError

  describe "exception/1 with tuple input" do
    test "creates exception from reason and response tuple" do
      response = ~s({"invalid": json})
      error = DecodeError.exception({:invalid_json, response})

      assert error.message == "Failed to decode response: :invalid_json"
      assert error.reason == :invalid_json
      assert error.response == response
    end

    test "creates exception for Jason decode error" do
      error = DecodeError.exception({%Jason.DecodeError{}, "bad json"})

      assert error.message =~ "Failed to decode response"
      assert error.response == "bad json"
    end

    test "can be raised with tuple" do
      assert_raise DecodeError, ~r/Failed to decode/, fn ->
        raise DecodeError, {:parse_error, "invalid"}
      end
    end
  end

  describe "exception/1 with single value input" do
    test "creates exception from atom reason" do
      error = DecodeError.exception(:unexpected_format)

      assert error.message == "Failed to decode response: :unexpected_format"
      assert error.reason == :unexpected_format
      assert error.response == nil
    end

    test "creates exception from Jason.DecodeError struct as reason" do
      jason_error = %Jason.DecodeError{data: "bad", position: 0, token: nil}
      error = DecodeError.exception(jason_error)

      assert error.message =~ "Failed to decode response"
      assert error.reason == jason_error
      assert error.response == nil
    end
  end

  describe "exception/1 with binary input" do
    test "creates exception from custom message" do
      error = DecodeError.exception("Invalid response format")

      assert error.message == "Invalid response format"
      assert error.reason == :decode_failed
      assert error.response == nil
    end

    test "can be raised with binary" do
      assert_raise DecodeError, "Parse error", fn ->
        raise DecodeError, "Parse error"
      end
    end
  end

  describe "exception/1 with keyword list input" do
    test "creates exception from keyword list with all fields" do
      error = DecodeError.exception(
        reason: :malformed_json,
        response: ~s({"bad": "json"}),
        message: "Could not parse JSON response"
      )

      assert error.message == "Could not parse JSON response"
      assert error.reason == :malformed_json
      assert error.response == ~s({"bad": "json"})
    end

    test "creates exception from keyword list with partial fields" do
      error = DecodeError.exception(
        reason: :invalid_format,
        response: "raw response"
      )

      assert error.message == "Failed to decode response: :invalid_format"
      assert error.reason == :invalid_format
      assert error.response == "raw response"
    end

    test "creates exception from keyword list with only reason" do
      error = DecodeError.exception(reason: :encoding_error)

      assert error.message == "Failed to decode response: :encoding_error"
      assert error.reason == :encoding_error
      assert error.response == nil
    end

    test "can be raised with keyword list" do
      assert_raise DecodeError, "JSON error", fn ->
        raise DecodeError, [reason: :json_error, message: "JSON error"]
      end
    end
  end

  describe "exception/1 with map input (atom keys)" do
    test "creates exception from map with all fields" do
      error = DecodeError.exception(%{
        reason: :parse_error,
        response: "invalid response",
        message: "Failed to parse response"
      })

      assert error.message == "Failed to parse response"
      assert error.reason == :parse_error
      assert error.response == "invalid response"
    end

    test "creates exception from map with only reason" do
      error = DecodeError.exception(%{reason: :unexpected_type})

      assert error.message == "Failed to decode response: :unexpected_type"
      assert error.reason == :unexpected_type
      assert error.response == nil
    end

    test "creates exception from empty map" do
      error = DecodeError.exception(%{})

      assert error.message == "Failed to decode response: :decode_failed"
      assert error.reason == :decode_failed
      assert error.response == nil
    end
  end

  describe "exception/1 with map input (string keys)" do
    test "creates exception from map with string keys" do
      error = DecodeError.exception(%{
        "reason" => :invalid_response_format,
        "response" => "<html>Error</html>",
        "message" => "Expected JSON but got HTML"
      })

      assert error.message == "Expected JSON but got HTML"
      assert error.reason == :invalid_response_format
      assert error.response == "<html>Error</html>"
    end

    test "creates exception from string key map with only reason" do
      error = DecodeError.exception(%{"reason" => :timeout})

      assert error.message == "Failed to decode response: :timeout"
      assert error.reason == :timeout
    end
  end

  describe "exception/1 with struct input" do
    test "creates exception from existing error struct" do
      original = %DecodeError{
        message: "Original error",
        reason: :invalid_json,
        response: "bad"
      }

      error = DecodeError.exception(original)

      assert error.message == "Original error"
      assert error.reason == :invalid_json
      assert error.response == "bad"
    end

    test "generates message if nil" do
      original = %DecodeError{
        message: nil,
        reason: :parse_error,
        response: nil
      }

      error = DecodeError.exception(original)

      assert error.message == "Failed to decode response: :parse_error"
      assert error.reason == :parse_error
    end
  end

  describe "message/1 callback" do
    test "returns the error message" do
      error = %DecodeError{
        message: "JSON parse error",
        reason: :invalid,
        response: nil
      }

      assert Exception.message(error) == "JSON parse error"
    end

    test "returns default message when nil" do
      error = %DecodeError{message: nil, reason: :error, response: nil}

      assert Exception.message(error) == "Failed to decode response"
    end
  end

  describe "integration with raise/rescue" do
    test "can pattern match on reason in rescue" do
      try do
        raise DecodeError, {:invalid_json, "bad json"}
      rescue
        e in DecodeError ->
          assert e.reason == :invalid_json
          assert e.response == "bad json"
      end
    end

    test "preserves all fields through raise/rescue" do
      try do
        raise DecodeError, %{
          reason: :malformed,
          response: ~s({"incomplete": ),
          message: "Incomplete JSON response"
        }
      rescue
        e in DecodeError ->
          assert e.reason == :malformed
          assert e.response == ~s({"incomplete": )
          assert e.message == "Incomplete JSON response"
      end
    end
  end

  describe "exception type verification" do
    test "is an exception" do
      error = DecodeError.exception(:error)

      assert is_exception(error)
    end

    test "implements Exception behavior" do
      behaviours =
        DecodeError.__info__(:attributes)
        |> Keyword.get_values(:behaviour)
        |> List.flatten()

      assert Exception in behaviours
    end
  end
end
