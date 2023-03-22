defmodule ExNylasTest.HTTP do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "client can handle an error response", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/job-statuses", fn conn ->
      Plug.Conn.resp(conn, 429, ~s<{"errorMessage": "Rate limit exceeded"}>)
    end)

    assert {:error, %{"errorMessage" => "Rate limit exceeded"}} ==
      ExNylas.Connection.new("id", "secret", "token", endpoint_url(bypass.port))
      |> ExNylas.Jobs.list()
  end

  test "client can recover from server downtime", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      # We don't care about `request_path` or `method` for this test.
      Plug.Conn.resp(conn, 200, ~s<[]>)
    end)

    assert {:ok, []} ==
      ExNylas.Connection.new("id", "secret", "token", endpoint_url(bypass.port))
      |> ExNylas.Jobs.list() # Nothing special about jobs here, any API would do

    # Blocks until the TCP socket is closed.
    Bypass.down(bypass)

    assert {:error, :econnrefused} ==
      ExNylas.Connection.new("id", "secret", "token", endpoint_url(bypass.port))
      |> ExNylas.Jobs.list()

    Bypass.up(bypass)

    assert {:ok, []} ==
      ExNylas.Connection.new("id", "secret", "token", endpoint_url(bypass.port))
      |> ExNylas.Jobs.list()
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
