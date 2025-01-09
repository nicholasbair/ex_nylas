defmodule ExNylas.HostedAuthenticationTest do
  use ExUnit.Case, async: true
  alias ExNylas.{HostedAuthentication, Connection}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "get_auth_url/2 returns the correct URL on success", %{bypass: bypass} do
    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id"
    }

    options = %{
      redirect_uri: "https://mycoolapp.com/auth",
      response_type: "code",
      scope: ["Mail.ReadWrite", "Mail.Send"],
      foo: nil
    }

    expected_url =
      "#{conn.api_server}/v3/connect/auth?client_id=#{conn.client_id}&scope=Mail.ReadWrite,Mail.Send&redirect_uri=https://mycoolapp.com/auth&response_type=code"

    {:ok, returned_url} = HostedAuthentication.get_auth_url(conn, options)

    assert URI.decode_query(expected_url) == URI.decode_query(returned_url)
  end

  test "get_auth_url/2 returns the correct URL using options struct", %{bypass: bypass} do
    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id"
    }

    options = %{
      redirect_uri: "https://mycoolapp.com/auth",
      response_type: "code",
      scope: ["Mail.ReadWrite", "Mail.Send"]
    }

    options = HostedAuthentication.build!(options)

    expected_url =
      "#{conn.api_server}/v3/connect/auth?client_id=#{conn.client_id}&scope=Mail.ReadWrite,Mail.Send&redirect_uri=https://mycoolapp.com/auth&response_type=code"

    {:ok, returned_url} = HostedAuthentication.get_auth_url(conn, options)

    assert URI.decode_query(expected_url) == URI.decode_query(returned_url)
  end

  test "get_auth_url/2 returns an error if client_id is missing", %{bypass: bypass} do
    conn = %Connection{
      api_server: endpoint_url(bypass.port)
    }

    options = %{
      redirect_uri: "https://mycoolapp.com/auth",
      response_type: "code"
    }

    assert {:error, "client_id on the connection struct is required for this call"} =
             HostedAuthentication.get_auth_url(conn, options)
  end

  test "get_auth_url!/2 returns the correct URL", %{bypass: bypass} do
    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id"
    }

    options = %{
      redirect_uri: "https://mycoolapp.com/auth",
      response_type: "code",
      scope: ["Mail.ReadWrite", "Mail.Send"]
    }

    options = HostedAuthentication.build!(options)

    expected_url =
      "#{conn.api_server}/v3/connect/auth?client_id=#{conn.client_id}&scope=Mail.ReadWrite,Mail.Send&redirect_uri=https://mycoolapp.com/auth&response_type=code"
      |> URI.decode_query()

    returned_url =
      conn
      |> HostedAuthentication.get_auth_url!(options)
      |> URI.decode_query()

    assert expected_url == returned_url
  end

  test "get_auth_url!/2 raises an error if client_id is missing", %{bypass: bypass} do
    conn = %Connection{
      api_server: endpoint_url(bypass.port)
    }

    options = %{
      redirect_uri: "https://mycoolapp.com/auth",
      response_type: "code"
    }

    assert_raise ExNylasError, fn ->
      HostedAuthentication.get_auth_url!(conn, options)
    end
  end

  test "get_auth_url!/2 raises an error if redirect_uri is missing", %{bypass: bypass} do
    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id"
    }

    options = %{
      response_type: "code"
    }

    assert_raise ExNylasError, fn ->
      HostedAuthentication.get_auth_url!(conn, options)
    end
  end

  test "get_auth_url/2 properly encodes login_hint with special characters", %{bypass: bypass} do
    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id"
    }

    options = %{
      redirect_uri: "https://mycoolapp.com/auth",
      response_type: "code",
      login_hint: "user+test@example.com"
    }

    {:ok, returned_url} = HostedAuthentication.get_auth_url(conn, options)
    decoded_params = URI.decode_query(URI.parse(returned_url).query)

    assert decoded_params["login_hint"] == "user+test@example.com"
    assert String.contains?(returned_url, "login_hint=user%2Btest%40example.com")
  end

  test "exchange_code_for_token/4 returns the access token on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{"access_token": "access-token"}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "client-secret"
    }

    code = "auth-code"
    redirect_uri = "https://mycoolapp.com/auth"

    assert {:ok, %HostedAuthentication.Grant{access_token: "access-token"}} =
             HostedAuthentication.exchange_code_for_token(conn, code, redirect_uri)
  end

  test "exchange_code_for_token/4 returns an error tuple on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(400, ~s<{"error": "Bad Request"}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "client-secret"
    }

    code = "auth-code"
    redirect_uri = "https://mycoolapp.com/auth"

    assert {:error, %HostedAuthentication.Error{error: "Bad Request"}} =
             HostedAuthentication.exchange_code_for_token(conn, code, redirect_uri)
  end

  test "exchange_code_for_token!/4 returns the access token on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{"access_token": "access-token"}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "client-secret"
    }

    code = "auth-code"
    redirect_uri = "https://mycoolapp.com/auth"

    expected = %ExNylas.HostedAuthentication.Grant{
      access_token: "access-token",
      email: nil,
      expires_in: nil,
      grant_id: nil,
      id_token: nil,
      provider: nil,
      refresh_token: nil,
      scope: nil,
      token_type: nil
    }

    assert expected == HostedAuthentication.exchange_code_for_token!(conn, code, redirect_uri)
  end

  test "exchange_code_for_token!/4 raises an error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/connect/token", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(400, ~s<{"error": "Bad Request"}>)
    end)

    conn = %Connection{
      api_server: endpoint_url(bypass.port),
      client_id: "client-id",
      api_key: "client-secret"
    }

    code = "auth-code"
    redirect_uri = "https://mycoolapp.com/auth"

    assert_raise ExNylasError, fn ->
      HostedAuthentication.exchange_code_for_token!(conn, code, redirect_uri)
    end
  end
end
