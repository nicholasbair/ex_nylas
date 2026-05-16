defmodule ExNylas.HostedAuthentication.ErrorTest do
  use ExUnit.Case, async: true
  alias ExNylas.HostedAuthentication.Error

  describe "exception/1 with binary input" do
    test "creates exception from simple error string" do
      error = Error.exception("invalid_grant")

      assert error.message == "OAuth error: invalid_grant"
      assert error.error == "invalid_grant"
      assert error.error_code == nil
      assert error.error_uri == nil
      assert error.request_id == nil
    end

    test "creates exception from descriptive error string" do
      error = Error.exception("access_denied")

      assert error.message == "OAuth error: access_denied"
      assert error.error == "access_denied"
    end

    test "can be raised with binary" do
      assert_raise Error, "OAuth error: invalid_client", fn ->
        raise Error, "invalid_client"
      end
    end

    test "can be rescued and accessed" do
      try do
        raise Error, "invalid_request"
      rescue
        e in Error ->
          assert e.error == "invalid_request"
          assert e.message == "OAuth error: invalid_request"
      end
    end
  end

  describe "exception/1 with keyword list input" do
    test "creates exception from keyword list with all fields" do
      error = Error.exception(
        error: "invalid_grant",
        error_code: 400,
        error_uri: "https://example.com/error",
        request_id: "req-123"
      )

      assert error.message == "OAuth error: invalid_grant"
      assert error.error == "invalid_grant"
      assert error.error_code == 400
      assert error.error_uri == "https://example.com/error"
      assert error.request_id == "req-123"
    end

    test "creates exception from keyword list with partial fields" do
      error = Error.exception(
        error: "access_denied",
        request_id: "req-456"
      )

      assert error.message == "OAuth error: access_denied"
      assert error.error == "access_denied"
      assert error.error_code == nil
      assert error.error_uri == nil
      assert error.request_id == "req-456"
    end

    test "creates exception from keyword list with only error" do
      error = Error.exception(error: "unauthorized_client")

      assert error.message == "OAuth error: unauthorized_client"
      assert error.error == "unauthorized_client"
      assert error.error_code == nil
    end

    test "can be raised with keyword list" do
      assert_raise Error, "OAuth error: server_error", fn ->
        raise Error, [error: "server_error", request_id: "abc123"]
      end
    end

    test "can be rescued and all fields accessed" do
      try do
        raise Error, [
          error: "invalid_scope",
          error_code: 403,
          request_id: "xyz789"
        ]
      rescue
        e in Error ->
          assert e.error == "invalid_scope"
          assert e.error_code == 403
          assert e.request_id == "xyz789"
      end
    end
  end

  describe "exception/1 with map input (atom keys)" do
    test "creates exception from map with all fields" do
      error = Error.exception(%{
        error: "invalid_grant",
        error_code: 401,
        error_uri: "https://docs.example.com",
        request_id: "req-789"
      })

      assert error.message == "OAuth error: invalid_grant"
      assert error.error == "invalid_grant"
      assert error.error_code == 401
      assert error.error_uri == "https://docs.example.com"
      assert error.request_id == "req-789"
    end

    test "creates exception from map with partial fields" do
      error = Error.exception(%{
        error: "temporarily_unavailable",
        request_id: "req-999"
      })

      assert error.message == "OAuth error: temporarily_unavailable"
      assert error.error == "temporarily_unavailable"
      assert error.request_id == "req-999"
      assert error.error_code == nil
      assert error.error_uri == nil
    end
  end

  describe "exception/1 with map input (string keys)" do
    test "creates exception from map with string keys" do
      error = Error.exception(%{
        "error" => "invalid_client",
        "error_code" => 400,
        "error_uri" => "https://example.com/errors",
        "request_id" => "req-abc"
      })

      assert error.message == "OAuth error: invalid_client"
      assert error.error == "invalid_client"
      assert error.error_code == 400
      assert error.error_uri == "https://example.com/errors"
      assert error.request_id == "req-abc"
    end

    test "creates exception from API-style response" do
      # This simulates what the API actually returns
      api_response = %{
        "error" => "invalid_grant",
        "request_id" => "nylas-req-123"
      }

      error = Error.exception(api_response)

      assert error.message == "OAuth error: invalid_grant"
      assert error.error == "invalid_grant"
      assert error.request_id == "nylas-req-123"
    end
  end

  describe "exception/1 with struct input" do
    test "creates exception from existing error struct" do
      original = %Error{
        error: "invalid_request",
        error_code: 400,
        request_id: "original-req"
      }

      error = Error.exception(original)

      assert error.message == "OAuth error: invalid_request"
      assert error.error == "invalid_request"
      assert error.error_code == 400
      assert error.request_id == "original-req"
    end

    test "updates message when error field is present" do
      original = %Error{
        message: "Old message",
        error: "new_error_code"
      }

      error = Error.exception(original)

      assert error.message == "OAuth error: new_error_code"
      assert error.error == "new_error_code"
    end
  end

  describe "exception/1 edge cases" do
    test "handles nil error field" do
      error = Error.exception(%{error: nil})

      assert error.message == "OAuth error: Authentication code exchange failed"
      assert error.error == nil
    end

    test "handles empty map" do
      error = Error.exception(%{})

      assert error.message == "OAuth error: Authentication code exchange failed"
      assert error.error == nil
      assert error.error_code == nil
      assert error.error_uri == nil
      assert error.request_id == nil
    end

    test "handles missing error field in map" do
      error = Error.exception(%{
        error_code: 500,
        request_id: "req-123"
      })

      assert error.message == "OAuth error: Authentication code exchange failed"
      assert error.error == nil
      assert error.error_code == 500
      assert error.request_id == "req-123"
    end

    test "handles empty keyword list" do
      error = Error.exception([])

      assert error.message == "OAuth error: Authentication code exchange failed"
      assert error.error == nil
    end
  end

  describe "message/1 callback" do
    test "returns the error message" do
      error = %Error{message: "OAuth error: test_error"}

      assert Exception.message(error) == "OAuth error: test_error"
    end

    test "returns default message when nil" do
      error = %Error{message: nil}

      assert Exception.message(error) == "OAuth error: Authentication code exchange failed"
    end
  end

  describe "integration with raise/rescue" do
    test "can pattern match on error field in rescue" do
      try do
        raise Error, error: "invalid_grant", request_id: "req-123"
      rescue
        e in [Error] ->
          assert e.error == "invalid_grant"
          assert e.request_id == "req-123"
      end
    end

    test "exception message is displayed correctly" do
      error = Error.exception("unsupported_grant_type")
      message = Exception.message(error)

      assert message == "OAuth error: unsupported_grant_type"
    end

    test "preserves all OAuth-specific fields through raise/rescue" do
      try do
        raise Error, %{
          error: "invalid_client",
          error_code: 401,
          error_uri: "https://oauth.net/2/grant-types/",
          request_id: "nylas-abc-123"
        }
      rescue
        e in Error ->
          assert e.error == "invalid_client"
          assert e.error_code == 401
          assert e.error_uri == "https://oauth.net/2/grant-types/"
          assert e.request_id == "nylas-abc-123"
          assert e.message == "OAuth error: invalid_client"
      end
    end
  end

  describe "exception type verification" do
    test "is an exception" do
      error = Error.exception("test")

      assert is_exception(error)
    end

    test "implements Exception behavior" do
      behaviours =
        Error.__info__(:attributes)
        |> Keyword.get_values(:behaviour)
        |> List.flatten()

      assert Exception in behaviours
    end
  end
end
