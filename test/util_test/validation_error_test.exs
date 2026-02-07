defmodule ExNylas.ValidationErrorTest do
  use ExUnit.Case, async: true
  alias ExNylas.ValidationError

  describe "exception/1 with tuple input" do
    test "creates exception from field atom and message" do
      error = ValidationError.exception({:email, "must be a valid email address"})

      assert error.message == "Validation failed for email: must be a valid email address"
      assert error.field == :email
      assert error.details == "must be a valid email address"
    end

    test "creates exception from field string and message" do
      error = ValidationError.exception({"username", "is required"})

      assert error.message == "Validation failed for username: is required"
      assert error.field == "username"
      assert error.details == "is required"
    end

    test "can be raised with tuple" do
      assert_raise ValidationError, ~r/Validation failed for/, fn ->
        raise ValidationError, {:name, "cannot be blank"}
      end
    end
  end

  describe "exception/1 with binary input" do
    test "creates exception from simple message" do
      error = ValidationError.exception("Invalid request parameters")

      assert error.message == "Invalid request parameters"
      assert error.field == nil
      assert error.details == nil
    end

    test "can be raised with binary" do
      assert_raise ValidationError, "Validation error", fn ->
        raise ValidationError, "Validation error"
      end
    end
  end

  describe "exception/1 with keyword list input" do
    test "creates exception from keyword list with all fields" do
      error = ValidationError.exception(
        field: :redirect_uri,
        details: "must be registered with the application",
        message: "Invalid redirect URI"
      )

      assert error.message == "Invalid redirect URI"
      assert error.field == :redirect_uri
      assert error.details == "must be registered with the application"
    end

    test "creates exception from keyword list with field and details" do
      error = ValidationError.exception(
        field: :client_id,
        details: "is required"
      )

      assert error.message == "Validation failed for client_id: is required"
      assert error.field == :client_id
      assert error.details == "is required"
    end

    test "creates exception from keyword list with only field" do
      error = ValidationError.exception(field: :api_key)

      assert error.message == "Validation failed for api_key"
      assert error.field == :api_key
      assert error.details == nil
    end

    test "creates exception from keyword list with only details" do
      error = ValidationError.exception(details: "Request body is malformed")

      assert error.message == "Request body is malformed"
      assert error.field == nil
      assert error.details == "Request body is malformed"
    end

    test "creates exception from keyword list with only message" do
      error = ValidationError.exception(message: "Custom validation error")

      assert error.message == "Custom validation error"
      assert error.field == nil
      assert error.details == nil
    end

    test "can be raised with keyword list" do
      assert_raise ValidationError, "Validation failed for email: invalid format", fn ->
        raise ValidationError, [field: :email, details: "invalid format"]
      end
    end
  end

  describe "exception/1 with map input (atom keys)" do
    test "creates exception from map with all fields" do
      error = ValidationError.exception(%{
        field: :grant_id,
        details: "not found",
        message: "Grant does not exist"
      })

      assert error.message == "Grant does not exist"
      assert error.field == :grant_id
      assert error.details == "not found"
    end

    test "creates exception from map with field and details" do
      error = ValidationError.exception(%{
        field: :scope,
        details: "must include at least one permission"
      })

      assert error.message == "Validation failed for scope: must include at least one permission"
      assert error.field == :scope
      assert error.details == "must include at least one permission"
    end

    test "creates exception from map with only field" do
      error = ValidationError.exception(%{field: :response_type})

      assert error.message == "Validation failed for response_type"
      assert error.field == :response_type
      assert error.details == nil
    end

    test "creates exception from empty map" do
      error = ValidationError.exception(%{})

      assert error.message == "Validation failed"
      assert error.field == nil
      assert error.details == nil
    end
  end

  describe "exception/1 with map input (string keys)" do
    test "creates exception from map with string keys" do
      error = ValidationError.exception(%{
        "field" => "email",
        "details" => "format is invalid",
        "message" => "Email validation failed"
      })

      assert error.message == "Email validation failed"
      assert error.field == "email"
      assert error.details == "format is invalid"
    end

    test "creates exception from string key map with field only" do
      error = ValidationError.exception(%{"field" => "password"})

      assert error.message == "Validation failed for password"
      assert error.field == "password"
    end
  end

  describe "exception/1 with struct input" do
    test "creates exception from existing error struct with message" do
      original = %ValidationError{
        message: "Custom error",
        field: :name,
        details: "too short"
      }

      error = ValidationError.exception(original)

      assert error.message == "Custom error"
      assert error.field == :name
      assert error.details == "too short"
    end

    test "generates message from field and details when message is nil" do
      original = %ValidationError{
        message: nil,
        field: :username,
        details: "already taken"
      }

      error = ValidationError.exception(original)

      assert error.message == "Validation failed for username: already taken"
      assert error.field == :username
      assert error.details == "already taken"
    end

    test "generates message from field only when details is nil" do
      original = %ValidationError{
        message: nil,
        field: :age,
        details: nil
      }

      error = ValidationError.exception(original)

      assert error.message == "Validation failed for age"
      assert error.field == :age
    end

    test "generates message from details when field is nil" do
      original = %ValidationError{
        message: nil,
        field: nil,
        details: "request is invalid"
      }

      error = ValidationError.exception(original)

      assert error.message == "request is invalid"
      assert error.details == "request is invalid"
    end

    test "generates default message when all fields are nil" do
      original = %ValidationError{
        message: nil,
        field: nil,
        details: nil
      }

      error = ValidationError.exception(original)

      assert error.message == "Validation failed"
    end
  end

  describe "message/1 callback" do
    test "returns the error message" do
      error = %ValidationError{
        message: "Validation error occurred",
        field: nil,
        details: nil
      }

      assert Exception.message(error) == "Validation error occurred"
    end

    test "returns default message when nil" do
      error = %ValidationError{message: nil, field: nil, details: nil}

      assert Exception.message(error) == "Validation failed"
    end
  end

  describe "integration with raise/rescue" do
    test "can pattern match on field in rescue" do
      try do
        raise ValidationError, {:email, "is required"}
      rescue
        e in ValidationError ->
          assert e.field == :email
          assert e.details == "is required"
      end
    end

    test "preserves all fields through raise/rescue" do
      try do
        raise ValidationError, %{
          field: :client_secret,
          details: "must be provided",
          message: "Missing client secret"
        }
      rescue
        e in ValidationError ->
          assert e.field == :client_secret
          assert e.details == "must be provided"
          assert e.message == "Missing client secret"
      end
    end
  end

  describe "exception type verification" do
    test "is an exception" do
      error = ValidationError.exception("error")

      assert is_exception(error)
    end

    test "implements Exception behavior" do
      behaviours =
        ValidationError.__info__(:attributes)
        |> Keyword.get_values(:behaviour)
        |> List.flatten()

      assert Exception in behaviours
    end
  end
end
