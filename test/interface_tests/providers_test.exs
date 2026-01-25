defmodule ExNylasTest.Providers do
  use ExUnit.Case, async: true
  alias ExNylas.{Providers, Response, Provider}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "detect/2 returns provider details on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/providers/detect", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{"data": {"provider": "google"}}>)
    end)

    params = [email: "user@example.com"]

    assert {:ok, %Response{data: %Provider{provider: :google}}} = Providers.detect(default_connection(bypass), params)
  end

  test "detect/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/providers/detect", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(400, ~s<{}>)
    end)

    params = [email: "user@example.com"]

    assert {:error, %ExNylas.APIError{status: :bad_request}} = Providers.detect(default_connection(bypass), params)
  end

  test "detect!/2 returns provider details on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/providers/detect", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{"data": {"provider": "google"}}>)
    end)

    params = [email: "user@example.com"]

    assert %Response{data: %Provider{provider: :google}} = Providers.detect!(default_connection(bypass), params)
  end

  test "detect!/2 raises an error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/providers/detect", fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(404, ~s<{"message": "Not Found"}>)
    end)

    params = [email: "user@example.com"]

    assert_raise ExNylas.APIError, fn ->
      Providers.detect!(default_connection(bypass), params)
    end
  end
end
