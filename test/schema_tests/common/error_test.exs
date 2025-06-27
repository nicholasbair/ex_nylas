defmodule ExNylas.ErrorTest do
  use ExUnit.Case, async: true
  alias ExNylas.Error

  describe "Error schema" do
    test "creates a valid error with all fields" do
      params = %{
        "message" => "Invalid request",
        "provider_error" => %{"code" => "INVALID_TOKEN", "details" => "Token expired"},
        "type" => "invalid_request_error"
      }
      changeset = Error.changeset(%Error{}, params)
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
      changeset = Error.changeset(%Error{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.message == nil
      assert error.provider_error == nil
      assert error.type == nil
    end

    test "handles empty map for provider_error" do
      params = %{"provider_error" => %{}}
      changeset = Error.changeset(%Error{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.provider_error == %{}
    end

    test "creates minimal error with only message" do
      params = %{"message" => "Something went wrong"}
      changeset = Error.changeset(%Error{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.message == "Something went wrong"
    end

    test "creates minimal error with empty params" do
      params = %{}
      changeset = Error.changeset(%Error{}, params)
      assert changeset.valid?
      error = Ecto.Changeset.apply_changes(changeset)
      assert error.message == nil
      assert error.provider_error == nil
      assert error.type == nil
    end
  end
end
