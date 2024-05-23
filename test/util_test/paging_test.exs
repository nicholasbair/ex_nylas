defmodule UtilTest.PagingTest do
  use ExUnit.Case, async: true
  import ExNylas.Paging

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "all does not page if there are no further results", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
      conn
      |> Plug.Conn.resp(200, ~s<{"data": {"id": "123", "grant_id": "456"}}>)
      |> Plug.Conn.put_resp_header("content-type", "application/json")
    end)

    res =
      ExNylas.Messages.list(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port)
        }
      )

    assert match?({:ok, _}, res)
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
