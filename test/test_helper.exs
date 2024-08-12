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

        params = [default_connection(bypass)] ++ unquote(params)

        apply(Module.concat(ExNylas, unquote(module)), unquote(function), params)
      end

      if unquote(function) in [:list, :list!, :first, :first!] do
        test "#{unquote(module)}.#{unquote(function)} includes the query in the request", %{bypass: bypass} do
          Bypass.expect_once(bypass, fn conn ->
            assert Enum.any?(conn.params, fn {k, v} -> k == "foo" and v == "bar" end)

            conn
            |> Plug.Conn.resp(200, unquote(expected)[:response])
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          end)

          params = [default_connection(bypass)] ++ unquote(params)

          apply(Module.concat(ExNylas, unquote(module)), unquote(function), params)
        end
      end

      if unquote(function) in [:first, :first!] do
        test "#{unquote(module)}.#{unquote(function)} includes limit=1 in the request", %{bypass: bypass} do
          Bypass.expect_once(bypass, fn conn ->
            assert Enum.any?(conn.params, fn {k, v} -> k == "limit" and v == "1" end)

            conn
            |> Plug.Conn.resp(200, unquote(expected)[:response])
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          end)

          params = [default_connection(bypass)] ++ unquote(params)

          apply(Module.concat(ExNylas, unquote(module)), unquote(function), params)
        end
      end

      test "#{unquote(module)}.#{unquote(function)} returns the common response struct", %{bypass: bypass} do
        Bypass.expect_once(bypass, fn conn ->
          conn
          |> Plug.Conn.resp(200, unquote(expected)[:response])
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        params = [default_connection(bypass)] ++ unquote(params)

        res = apply(Module.concat(ExNylas, unquote(module)), unquote(function), params)
        pattern = unquote(expected)[:assert_pattern]

        assert match?(pattern, res)
        assert get_struct(res) == ExNylas.Response
      end

      if unquote(function) in [:create, :create!, :update, :update!] do
        test "#{unquote(module)}.#{unquote(function)} passes the request payload", %{bypass: bypass} do
          Bypass.expect_once(bypass, fn conn ->
            {:ok, body, conn} = Plug.Conn.read_body(conn)

            assert body == ~s<{"foo":"bar"}>

            conn
            |> Plug.Conn.resp(200, unquote(expected)[:response])
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          end)

          params = [default_connection(bypass)] ++ unquote(params)

          apply(Module.concat(ExNylas, unquote(module)), unquote(function), params)
        end
      end
    end
  end

  def endpoint_url(port), do: "http://localhost:#{port}/"

  def default_connection(bypass) do
    %ExNylas.Connection{
      api_key: "api_key",
      grant_id: "grant_id",
      api_server: endpoint_url(bypass.port),
      options: [retry: false]
    }
  end

  def get_struct({:ok, res}), do: res.__struct__
  def get_struct(res), do: res.__struct__
end
