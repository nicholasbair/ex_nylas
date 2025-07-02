defmodule ExNylas.Paging.OptionsTest do
  use ExUnit.Case, async: true

  alias ExNylas.Paging.Options

  describe "from_opts/1" do
    test "converts keyword list to struct with defaults" do
      opts = [query: [limit: 10], delay: 1000]

      result = Options.from_opts(opts)

      assert result.query == [limit: 10]
      assert result.delay == 1000
      assert result.send_to == nil
      assert result.with_metadata == nil
    end

    test "converts map to struct with defaults" do
      opts = %{query: %{limit: 10}, delay: 1000}

      result = Options.from_opts(opts)

      assert result.query == %{limit: 10}
      assert result.delay == 1000
      assert result.send_to == nil
      assert result.with_metadata == nil
    end

    test "uses default values when options are not provided" do
      result = Options.from_opts([])

      assert result.query == []
      assert result.delay == 0
      assert result.send_to == nil
      assert result.with_metadata == nil
    end

    test "handles send_to and with_metadata options" do
      send_to_fn = fn _ -> :ok end
      opts = [send_to: send_to_fn, with_metadata: :test_meta]

      result = Options.from_opts(opts)

      assert result.send_to == send_to_fn
      assert result.with_metadata == :test_meta
    end
  end
end
