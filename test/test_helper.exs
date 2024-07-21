ExUnit.start()

defmodule ExNylasTest.Helper do
  use ExUnit.Case, async: true

  defmacro generate_test(module, function, params, expected) do
    quote do
      test "#{unquote(module)}.#{unquote(function)} calls #{unquote(expected)[:method]}", %{bypass: bypass} do
        Bypass.expect_once(bypass, fn conn ->
          assert conn.method == unquote(expected)[:method]

          conn
          |> Plug.Conn.resp(200, unquote(expected)[:response])
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        params = [
          %ExNylas.Connection{
            api_key: "1234",
            grant_id: "1234",
            api_server: endpoint_url(bypass.port),
          }
        ] ++ unquote(params)

        res = apply(Module.concat(ExNylas, unquote(module)), unquote(function), params)
        pattern = unquote(expected)[:assert_pattern]

        assert match?(pattern, res)
      end
    end
  end
end
