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

    assert {:error, %ExNylas.Response{status: :not_found}} = Grants.me(conn)
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

    assert_raise ExNylas.APIError, fn ->
      Grants.me!(conn)
    end
  end

  # Helper function for refresh token tests setup
  defp setup_refresh_test(bypass, status, response) do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.send_resp(status, response)
    end)

    %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "api-key",
      options: []
    }
  end

  test "refresh/2 returns new token on success", %{bypass: bypass} do
    success_response = ~s<{
      "access_token": "new-access-token",
      "refresh_token": "new-refresh-token",
      "scope": "https://www.googleapis.com/auth/gmail.readonly profile",
      "token_type": "Bearer",
      "id_token": "id-token",
      "grant_id": "grant-id"
    }>
    
    conn = setup_refresh_test(bypass, 200, success_response)

    assert {:ok, grant} = Grants.refresh(conn, "refresh-token")
    assert grant.access_token == "new-access-token"
    assert grant.refresh_token == "new-refresh-token"
    assert grant.grant_id == "grant-id"
  end

  test "refresh/2 returns error on failure", %{bypass: bypass} do
    error_response = ~s<{"error": "invalid_grant", "error_description": "Refresh token invalid"}>
    conn = setup_refresh_test(bypass, 400, error_response)

    assert {:error, %ExNylas.Response{status: :bad_request}} = Grants.refresh(conn, "invalid-refresh-token")
  end

  test "refresh!/2 returns new token on success", %{bypass: bypass} do
    success_response = ~s<{
      "access_token": "new-access-token",
      "refresh_token": "new-refresh-token",
      "scope": "https://www.googleapis.com/auth/gmail.readonly profile",
      "token_type": "Bearer",
      "id_token": "id-token",
      "grant_id": "grant-id"
    }>
    
    conn = setup_refresh_test(bypass, 200, success_response)

    assert grant = Grants.refresh!(conn, "refresh-token")
    assert grant.access_token == "new-access-token"
    assert grant.refresh_token == "new-refresh-token"
    assert grant.grant_id == "grant-id"
  end

  test "refresh!/2 raises error on failure", %{bypass: bypass} do
    error_response = ~s<{"error": "invalid_grant", "error_description": "Refresh token invalid"}>
    conn = setup_refresh_test(bypass, 400, error_response)

    assert_raise ExNylas.APIError, ~r/API request failed with status bad_request.*/, fn ->
      Grants.refresh!(conn, "invalid-refresh-token")
    end
  end
end
