defmodule ExNylasTest.HTTP do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "client can handle an unsuccessful request", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
      conn
      |> Plug.Conn.resp(429, ~s<{"error": "some error"}>)
      |> Plug.Conn.put_resp_header("content-type", "application/json")
    end)

    res =
      ExNylas.Messages.list(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        }
      )

    assert match?({:error, _}, res)
  end

  test "client can recover from server downtime", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      # We don't care about `request_path` or `method` for this test.
      Plug.Conn.resp(conn, 200, ~s<[]>)
    end)

    res =
      ExNylas.Messages.list(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        }
      )

    assert match?({:ok, _}, res)

    # Blocks until the TCP socket is closed.
    Bypass.down(bypass)

    res =
      ExNylas.Messages.list(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        }
      )

    assert match?({:error, _}, res)

    Bypass.up(bypass)

    res =
      ExNylas.Messages.list(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        }
      )

    assert match?({:ok, _}, res)
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
