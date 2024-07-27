defmodule ExNylasTest.Grants do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper
  alias ExNylas.{
    Grants,
    Grant,
    Response,
    Connection
  }

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "me/1 returns grant on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/me", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(200, ~s<{"data": {"id": "grant-id"}}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      grant_id: "me",
      access_token: "fake-token",
      options: []
    }

    assert {:ok, %Response{data: %Grant{id: "grant-id"}}} = Grants.me(conn)
  end

  test "me/1 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/me", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(404, ~s<{"message": "Not Found"}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      grant_id: "me",
      access_token: "fake-token",
      options: []
    }

    assert {:error, %Response{status: :not_found, data: nil}} = Grants.me(conn)
  end

  test "me!/1 returns grant on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/me", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(200, ~s<{"data": {"id": "grant-id"}}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      grant_id: "me",
      access_token: "fake-token",
      options: []
    }

    assert %Response{data: %Grant{id: "grant-id"}} = Grants.me!(conn)
  end

  test "me!/1 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/me", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(404, ~s<{"message": "Not Found"}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      grant_id: "me",
      access_token: "fake-token",
      options: []
    }

    assert_raise ExNylasError, fn ->
      Grants.me!(conn)
    end
  end
end
