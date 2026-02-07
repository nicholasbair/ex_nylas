defmodule ExNylas.ErrorTest do
  use ExUnit.Case, async: true
  alias ExNylas.Error

  defmodule TestStruct1 do
    defstruct [:field]
  end

  defmodule TestStruct2 do
    defstruct [:data, :id]
  end

  defmodule TestStruct3 do
    defstruct [:name]
  end

  describe "exception/1 with struct input" do
    test "creates exception for arbitrary struct" do
      struct = %TestStruct1{field: "value"}
      error = Error.exception(struct)

      assert error.message == "Unexpected error struct: ExNylas.ErrorTest.TestStruct1"
      assert error.reason == :unexpected_struct
      assert error.original == struct
    end

    test "preserves original struct in original field" do
      struct = %TestStruct2{data: "test", id: 123}
      error = Error.exception(struct)

      assert error.original == struct
      assert error.original.data == "test"
      assert error.original.id == 123
    end

    test "can be raised with struct" do
      assert_raise Error, ~r/Unexpected error struct/, fn ->
        raise Error, %TestStruct3{name: "test"}
      end
    end
  end

  describe "exception/1 with binary input" do
    test "creates exception from string" do
      error = Error.exception("Something went wrong")

      assert error.message == "Unexpected error: Something went wrong"
      assert error.reason == :unexpected_error
      assert error.original == "Something went wrong"
    end

    test "preserves original string" do
      error = Error.exception("timeout error")

      assert error.original == "timeout error"
    end

    test "can be raised with binary" do
      assert_raise Error, "Unexpected error: Custom error message", fn ->
        raise Error, "Custom error message"
      end
    end
  end

  describe "exception/1 with other input types" do
    test "creates exception from atom" do
      error = Error.exception(:timeout)

      assert error.message == "Unexpected error: :timeout"
      assert error.reason == :unexpected_error
      assert error.original == :timeout
    end

    test "creates exception from integer" do
      error = Error.exception(404)

      assert error.message == "Unexpected error: 404"
      assert error.reason == :unexpected_error
      assert error.original == 404
    end

    test "creates exception from list" do
      error = Error.exception([1, 2, 3])

      assert error.message == "Unexpected error: [1, 2, 3]"
      assert error.reason == :unexpected_error
      assert error.original == [1, 2, 3]
    end

    test "creates exception from map" do
      map = %{error: "something", code: 500}
      error = Error.exception(map)

      assert error.message =~ "Unexpected error:"
      assert error.reason == :unexpected_error
      assert error.original == map
    end

    test "creates exception from tuple" do
      tuple = {:error, "failed"}
      error = Error.exception(tuple)

      assert error.message == "Unexpected error: {:error, \"failed\"}"
      assert error.reason == :unexpected_error
      assert error.original == tuple
    end
  end

  describe "message/1 callback" do
    test "returns the error message" do
      error = %Error{
        message: "Custom error",
        reason: :unexpected_error,
        original: "test"
      }

      assert Exception.message(error) == "Custom error"
    end

    test "returns default message when nil" do
      error = %Error{
        message: nil,
        reason: :unexpected_error,
        original: "test"
      }

      assert Exception.message(error) == "Unexpected error"
    end
  end

  defmodule TestStruct4 do
    defstruct [:value]
  end

  describe "integration with raise/rescue" do
    test "can pattern match on reason in rescue" do
      try do
        raise Error, "something bad"
      rescue
        e in Error ->
          assert e.reason == :unexpected_error
          assert e.message =~ "something bad"
      end
    end

    test "can pattern match on struct type in rescue" do
      try do
        raise Error, %TestStruct4{value: 42}
      rescue
        e in Error ->
          assert e.reason == :unexpected_struct
          assert e.original.value == 42
      end
    end

    test "preserves all fields through raise/rescue" do
      original_data = %{code: 123, message: "fail"}

      try do
        raise Error, original_data
      rescue
        e in Error ->
          assert e.reason == :unexpected_error
          assert e.original == original_data
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

  defmodule TestStruct5 do
    defstruct [:field]
  end

  describe "use in ResponseHandler" do
    test "wraps unexpected error values from ResponseHandler" do
      # This tests the actual usage in ResponseHandler
      result = ExNylas.ResponseHandler.handle_response({:error, "unexpected"})

      assert {:error, %Error{} = error} = result
      assert error.original == "unexpected"
      assert error.reason == :unexpected_error
    end

    test "wraps unexpected struct from ResponseHandler" do
      # Simulate what happens when an unexpected struct comes through
      result = ExNylas.ResponseHandler.handle_response({:error, %TestStruct5{field: "test"}})

      assert {:error, %Error{} = error} = result
      assert error.reason == :unexpected_struct
      assert %TestStruct5{} = error.original
    end
  end
end
