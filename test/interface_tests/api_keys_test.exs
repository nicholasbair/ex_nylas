defmodule ExNylas.APIKeysTest do
  use ExUnit.Case, async: true
  alias ExNylas.{APIKeys, Response, APIKey}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "create/7 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/admin/applications/app_id/api-keys", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"api_key": "api-key-id"}}>)
    end)

    body = %{
      name: "My API Key",
      expires_in: 90
    }

    assert {:ok, %Response{data: %APIKey{api_key: "api-key-id"}}} =
      APIKeys.create(
        default_connection(bypass),
        "app_id",
        body,
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "create/7 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/admin/applications/app_id/api-keys", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    body = %{
      name: "My API Key",
      expires_in: 90
    }

    assert {:error, %ExNylas.Response{status: :bad_request}} =
      APIKeys.create(
        default_connection(bypass),
        "app_id",
        body,
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "create!/7 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/admin/applications/app_id/api-keys", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"api_key": "api-key-id"}}>)
    end)

    body = %{
      name: "My API Key",
      expires_in: 90
    }

    assert %Response{data: %APIKey{api_key: "api-key-id"}} =
      APIKeys.create!(
        default_connection(bypass),
        "app_id",
        body,
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "create!/7 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/admin/applications/app_id/api-keys", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    body = %{
      name: "My API Key",
      expires_in: 90
    }

    assert_raise ExNylas.APIError, fn ->
      APIKeys.create!(
        default_connection(bypass),
        "app_id",
        body,
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
    end
  end

  test "list/6 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/admin/applications/app_id/api-keys", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": [{"api_key": "api-key-id"}]}>)
    end)

    assert {:ok, %Response{data: [%APIKey{api_key: "api-key-id"}]}} =
      APIKeys.list(
        default_connection(bypass),
        "app_id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "list/6 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/admin/applications/app_id/api-keys", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %ExNylas.Response{status: :bad_request}} =
      APIKeys.list(
        default_connection(bypass),
        "app_id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "list!/6 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/admin/applications/app_id/api-keys", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": [{"api_key": "api-key-id"}]}>)
    end)

    assert %Response{data: [%APIKey{api_key: "api-key-id"}]} =
      APIKeys.list!(
        default_connection(bypass),
        "app_id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "list!/6 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/admin/applications/app_id/api-keys", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, fn ->
      APIKeys.list!(
        default_connection(bypass),
        "app_id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
    end
  end

  test "find/7 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/admin/applications/app_id/api-keys/api-key-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"api_key": "api-key-id"}}>)
    end)

    assert {:ok, %Response{data: %APIKey{api_key: "api-key-id"}}} =
      APIKeys.find(
        default_connection(bypass),
        "app_id",
        "api-key-id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "find/7 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/admin/applications/app_id/api-keys/api-key-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %ExNylas.Response{status: :bad_request}} =
      APIKeys.find(
        default_connection(bypass),
        "app_id",
        "api-key-id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "find!/7 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/admin/applications/app_id/api-keys/api-key-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"api_key": "api-key-id"}}>)
    end)

    assert %Response{data: %APIKey{api_key: "api-key-id"}} =
      APIKeys.find!(
        default_connection(bypass),
        "app_id",
        "api-key-id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "find!/7 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/admin/applications/app_id/api-keys/api-key-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, fn ->
      APIKeys.find!(
        default_connection(bypass),
        "app_id",
        "api-key-id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
    end
  end

  test "delete/7 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "DELETE", "/v3/admin/applications/app_id/api-keys/api-key-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    assert {:ok, %Response{}} =
      APIKeys.delete(
        default_connection(bypass),
        "app_id",
        "api-key-id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "delete/7 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "DELETE", "/v3/admin/applications/app_id/api-keys/api-key-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %ExNylas.Response{status: :bad_request}} =
      APIKeys.delete(
        default_connection(bypass),
        "app_id",
        "api-key-id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "delete!/7 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "DELETE", "/v3/admin/applications/app_id/api-keys/api-key-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    assert %Response{} =
      APIKeys.delete!(
        default_connection(bypass),
        "app_id",
        "api-key-id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
  end

  test "delete!/7 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "DELETE", "/v3/admin/applications/app_id/api-keys/api-key-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, fn ->
      APIKeys.delete!(
        default_connection(bypass),
        "app_id",
        "api-key-id",
        "signature",
        "kid",
        "nonce",
        "timestamp"
      )
    end
  end
end
