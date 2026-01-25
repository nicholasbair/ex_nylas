defmodule ExNylasTest.CalendarFreeBusy do
  use ExUnit.Case, async: true
  alias ExNylas.{CalendarFreeBusy, Response}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "list/2 returns free/busy information on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{}>)
    end)

    body = %{"start_time" => 1615289235, "end_time" => 1615329235}

    assert {:ok, %Response{}} = CalendarFreeBusy.list(default_connection(bypass), body)
  end

  test "list/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(400, ~s<{}>)
    end)

    body = %{"start_time" => 1615289235, "end_time" => 1615329235}

    assert {:error, %ExNylas.APIError{status: :bad_request}} = CalendarFreeBusy.list(default_connection(bypass), body)
  end

  test "list!/2 returns free/busy information on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{}>)
    end)

    body = %{"start_time" => 1615289235, "end_time" => 1615329235}

    assert %Response{} = CalendarFreeBusy.list!(default_connection(bypass), body)
  end

  test "list!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(400, ~s<{}>)
    end)

    body = %{"start_time" => 1615289235, "end_time" => 1615329235}

    assert_raise ExNylas.APIError, fn ->
      CalendarFreeBusy.list!(default_connection(bypass), body)
    end
  end
end
