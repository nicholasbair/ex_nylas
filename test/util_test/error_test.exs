defmodule ExNylasTest.Error do
  use ExUnit.Case, async: true

  test "ExNylas.Error includes the correct message" do
    assert_raise ExNylasError, "Error: \"error message\"", fn ->
      raise ExNylasError, "error message"
    end
  end
end
