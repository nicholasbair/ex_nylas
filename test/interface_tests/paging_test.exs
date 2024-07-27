defmodule ExNylasTest.Paging do
  use ExUnit.Case, async: true
  alias ExNylas.{Paging, Response, Messages}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "all/4 returns paginated results with cursor paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"]}>)
    end)

    assert {:ok, ["result1"]} = Paging.all(default_connection(bypass), Messages, true)
  end

  test "all/4 returns error on failure with cursor paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %Response{status: :bad_request}} = Paging.all(default_connection(bypass), Messages, true)
  end

  test "all/4 returns paginated results with offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"], "limit": 50, "offset": 0}>)
    end)

    assert {:ok, ["result1"]} = Paging.all(default_connection(bypass), Messages, false)
  end

  test "all/4 returns error on failure with offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %Response{status: :bad_request}} = Paging.all(default_connection(bypass), Messages, false)
  end

  test "all!/4 returns paginated results with cursor paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"]}>)
    end)

    assert ["result1"] = Paging.all!(default_connection(bypass), Messages, true)
  end

  test "all!/4 raises error on failure with cursor paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylasError, fn ->
      Paging.all!(default_connection(bypass), Messages, true)
    end
  end

  test "all!/4 returns paginated results with offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"], "limit": 50, "offset": 0}>)
    end)

    assert ["result1"] = Paging.all!(default_connection(bypass), Messages, false)
  end

  test "all!/4 raises error on failure with offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylasError, fn ->
      Paging.all!(default_connection(bypass), Messages, false)
    end
  end
end
