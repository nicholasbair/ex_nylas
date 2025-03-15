defmodule ExNylasTest.Grants do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper
  alias ExNylas.{
    Grants,
    Grant,
    Response,
    Connection
  }
  
  # ExNylasError is defined at the top level
  alias ExNylasError

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

  test "refresh/2 returns new token on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(200, ~s<{
        "access_token": "new-access-token",
        "refresh_token": "new-refresh-token",
        "scope": "https://www.googleapis.com/auth/gmail.readonly profile",
        "token_type": "Bearer",
        "id_token": "id-token",
        "grant_id": "grant-id"
      }>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "api-key",
      options: []
    }

    assert {:ok, grant} = Grants.refresh(conn, "refresh-token")
    assert grant.access_token == "new-access-token"
    assert grant.refresh_token == "new-refresh-token"
    assert grant.grant_id == "grant-id"
  end

  test "refresh/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(400, ~s<{"error": "invalid_grant", "error_description": "Refresh token invalid"}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "api-key",
      options: []
    }

    assert {:error, %Response{status: :bad_request}} = Grants.refresh(conn, "invalid-refresh-token")
  end

  test "refresh!/2 returns new token on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(200, ~s<{
        "access_token": "new-access-token",
        "refresh_token": "new-refresh-token",
        "scope": "https://www.googleapis.com/auth/gmail.readonly profile",
        "token_type": "Bearer",
        "id_token": "id-token",
        "grant_id": "grant-id"
      }>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "api-key",
      options: []
    }

    assert grant = Grants.refresh!(conn, "refresh-token")
    assert grant.access_token == "new-access-token"
    assert grant.refresh_token == "new-refresh-token"
    assert grant.grant_id == "grant-id"
  end

  test "refresh!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(400, ~s<{"error": "invalid_grant", "error_description": "Refresh token invalid"}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "api-key",
      options: []
    }

    assert_raise ExNylasError, fn ->
      Grants.refresh!(conn, "invalid-refresh-token")
    end
  end
end
