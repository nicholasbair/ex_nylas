defmodule ExNylas.APIErrorTest do
  use ExUnit.Case, async: true
  alias ExNylas.APIError

  describe "Error schema" do
    test "creates a valid error with all fields" do
      params = %{
        "message" => "Invalid request",
        "provider_error" => %{"code" => "INVALID_TOKEN", "details" => "Token expired"},
        "type" => "invalid_request_error"
      }
      changeset = APIError.changeset(%APIError{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.message == "Invalid request"
      assert error.provider_error == %{"code" => "INVALID_TOKEN", "details" => "Token expired"}
      assert error.type == "invalid_request_error"
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "message" => nil,
        "provider_error" => nil,
        "type" => nil
      }
      changeset = APIError.changeset(%APIError{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.message == nil
      assert error.provider_error == nil
      assert error.type == nil
    end

    test "handles empty map for provider_error" do
      params = %{"provider_error" => %{}}
      changeset = APIError.changeset(%APIError{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.provider_error == %{}
    end

    test "creates minimal error with only message" do
      params = %{"message" => "Something went wrong"}
      changeset = APIError.changeset(%APIError{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.message == "Something went wrong"
    end

    test "creates minimal error with empty params" do
      params = %{}
      changeset = APIError.changeset(%APIError{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.message == nil
      assert error.provider_error == nil
      assert error.type == nil
    end
  end

  describe "Exception behavior" do
    test "creates exception from binary message" do
      error = APIError.exception("Request failed")

      assert error.message == "Request failed"
      assert error.type == nil
      assert error.provider_error == nil
    end

    test "creates exception from keyword list with all fields" do
      error = APIError.exception(
        message: "Invalid request",
        type: "invalid_request_error",
        provider_error: %{"code" => "AUTH_FAILED"}
      )

      assert error.message == "Invalid request"
      assert error.type == "invalid_request_error"
      assert error.provider_error == %{"code" => "AUTH_FAILED"}
    end

    test "creates exception from keyword list with partial fields" do
      error = APIError.exception(
        message: "Not found",
        type: "not_found_error"
      )

      assert error.message == "Not found"
      assert error.type == "not_found_error"
      assert error.provider_error == nil
    end

    test "creates exception from map with atom keys" do
      error = APIError.exception(%{
        message: "Rate limited",
        type: "rate_limit_error"
      })

      assert error.message == "Rate limited"
      assert error.type == "rate_limit_error"
    end

    test "creates exception from map with string keys" do
      error = APIError.exception(%{
        "message" => "Server error",
        "type" => "server_error",
        "provider_error" => %{"details" => "Internal"}
      })

      assert error.message == "Server error"
      assert error.type == "server_error"
      assert error.provider_error == %{"details" => "Internal"}
    end

    test "creates exception from existing APIError struct" do
      original = %APIError{
        message: "Original",
        type: "error_type"
      }

      error = APIError.exception(original)

      assert error.message == "Original"
      assert error.type == "error_type"
    end

    test "generates default message for struct with nil message" do
      original = %APIError{message: nil, type: nil}

      error = APIError.exception(original)

      assert error.message == "API request failed"
    end

    test "generates default message for empty map" do
      error = APIError.exception(%{})

      assert error.message == "API request failed"
      assert error.type == nil
      assert error.provider_error == nil
    end

    test "can be raised with binary" do
      assert_raise APIError, "API error", fn ->
        raise APIError, "API error"
      end
    end

    test "can be raised with keyword list" do
      assert_raise APIError, "Invalid grant", fn ->
        raise APIError, [message: "Invalid grant", type: "auth_error"]
      end
    end

    test "can be raised with map" do
      assert_raise APIError, "Unauthorized", fn ->
        raise APIError, %{message: "Unauthorized"}
      end
    end

    test "preserves all fields through raise/rescue" do
      try do
        raise APIError, %{
          message: "Permission denied",
          type: "permission_error",
          provider_error: %{"code" => "DENIED"}
        }
      rescue
        e in APIError ->
          assert e.message == "Permission denied"
          assert e.type == "permission_error"
          assert e.provider_error == %{"code" => "DENIED"}
      end
    end

    test "message/1 returns the error message" do
      error = %APIError{message: "Custom error"}

      assert Exception.message(error) == "Custom error"
    end

    test "message/1 returns default when nil" do
      error = %APIError{message: nil}

      assert Exception.message(error) == "API request failed"
    end

    test "is an exception" do
      error = APIError.exception("test")

      assert is_exception(error)
    end
  end
end
