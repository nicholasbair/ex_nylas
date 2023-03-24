defmodule ExNylasTest do
  use ExUnit.Case, async: true

  defp generate_tests(opts) do
    include = Keyword.get(opts, :include, [])
    object = Keyword.get(opts, :object)
    struct_name = Keyword.get(opts, :struct)
    bypass = Keyword.get(opts, :bypass)

    configs = ExNylas.api_configs()

    configs
    |> Map.keys()
    |> Enum.filter(fn k -> k in include end)
    |> Enum.map(fn k ->
      Map.get(configs, k)
      |> generate_test(object, struct_name, bypass)
    end)
  end

  defp generate_test(%{name: :find} = config, object, struct_name, bypass) do
    quote do
      test "#{unquote(struct_name)}.#{unquote(config.name)} makes a call to #{unquote(config.http_method)} /#{unquote(object)}", %{bypass: unquote(bypass)} do
        Bypass.expect_once(unquote(bypass), unquote(config.http_method), "/#{unquote(object)}", fn conn ->
          Plug.Conn.resp(conn, 200, ~s<{"id": "1234"}>)
        end)

        apply(unquote(struct_name), unquote(config.name), ExNylas.Connection.new("id", "secret", "token", "http://localhost:#{unquote(bypass.port)}/"))

        assert 1 == 2
      end
    end
  end

  defmacro __using__(opts) do
    quote do
      unquote(generate_tests(opts))
    end
  end

end
