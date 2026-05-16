defmodule ExNylasTest.Paging do
  use ExUnit.Case, async: true
  alias ExNylas.{Paging, Messages}
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

    assert {:ok, ["result1"]} = Paging.all(default_connection(bypass), &Messages.list/2, true)
  end

  test "all/4 returns error on failure with cursor paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %ExNylas.Response{status: :bad_request}} = Paging.all(default_connection(bypass), &Messages.list/2, true)
  end

  test "all/4 returns paginated results with offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"], "limit": 50, "offset": 0}>)
    end)

    assert {:ok, ["result1"]} = Paging.all(default_connection(bypass), &Messages.list/2, false)
  end

  test "all/4 returns error on failure with offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %ExNylas.Response{status: :bad_request}} = Paging.all(default_connection(bypass), &Messages.list/2, false)
  end

  test "all!/4 returns paginated results with cursor paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"]}>)
    end)

    assert ["result1"] = Paging.all!(default_connection(bypass), &Messages.list/2, true)
  end

  test "all!/4 raises error on failure with cursor paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, fn ->
      Paging.all!(default_connection(bypass), &Messages.list/2, true)
    end
  end

  test "all!/4 returns paginated results with offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"], "limit": 50, "offset": 0}>)
    end)

    assert ["result1"] = Paging.all!(default_connection(bypass), &Messages.list/2, false)
  end

  test "all!/4 raises error on failure with offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, fn ->
      Paging.all!(default_connection(bypass), &Messages.list/2, false)
    end
  end

  test "all!/4 raises error with custom message when response has no error struct (cursor)", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(500, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, ~r/API request failed with status/, fn ->
      Paging.all!(default_connection(bypass), &Messages.list/2, true)
    end
  end

  test "all!/4 raises error with custom message when response has no error struct (offset)", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(500, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, ~r/API request failed with status/, fn ->
      Paging.all!(default_connection(bypass), &Messages.list/2, false)
    end
  end

  test "all!/4 raises raw exception when error is not a Response (cursor)", %{bypass: bypass} do
    Bypass.down(bypass)

    assert_raise ExNylas.TransportError, fn ->
      Paging.all!(default_connection(bypass), &Messages.list/2, true)
    end
  end

  test "all!/4 raises raw exception when error is not a Response (offset)", %{bypass: bypass} do
    Bypass.down(bypass)

    assert_raise ExNylas.TransportError, fn ->
      Paging.all!(default_connection(bypass), &Messages.list/2, false)
    end
  end

  test "all/4 works with explicit empty opts for cursor paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result"]}>)
    end)

    assert {:ok, ["result"]} = Paging.all(default_connection(bypass), &Messages.list/2, true, [])
  end

  test "all/4 works with explicit empty opts for offset paging", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result"], "limit": 50, "offset": 0}>)
    end)

    assert {:ok, ["result"]} = Paging.all(default_connection(bypass), &Messages.list/2, false, [])
  end

  test "all/4 handles multiple pages with cursor paging", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      query_string = conn.query_string || ""

      cond do
        query_string == "" or query_string == "page_token=" ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, ~s<{"data": ["result1"], "next_cursor": "cursor123"}>)

        String.contains?(query_string, "page_token=cursor123") ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, ~s<{"data": ["result2"]}>)

        true ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(400, ~s<{}>)
      end
    end)

    assert {:ok, ["result1", "result2"]} = Paging.all(default_connection(bypass), &Messages.list/2, true)
  end

  test "all/4 handles multiple pages with offset paging", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      query_params = URI.decode_query(conn.query_string)
      offset = Map.get(query_params, "offset", "0")

      case offset do
        "0" ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, ~s<{"data": ["a", "b"], "limit": 2, "offset": 0}>)

        "2" ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, ~s<{"data": ["c"], "limit": 2, "offset": 2}>)
      end
    end)

    assert {:ok, ["a", "b", "c"]} = Paging.all(default_connection(bypass), &Messages.list/2, false, query: %{limit: 2})
  end

  test "all!/4 raises APIError when error is embedded in Response (cursor)", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{"error": {"type": "invalid_request", "message": "Bad request"}}>)
    end)

    assert_raise ExNylas.APIError, fn ->
      Paging.all!(default_connection(bypass), &Messages.list/2, true)
    end
  end

  test "all!/4 raises APIError when error is embedded in Response (offset)", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{"error": {"type": "invalid_request", "message": "Bad request"}}>)
    end)

    assert_raise ExNylas.APIError, fn ->
      Paging.all!(default_connection(bypass), &Messages.list/2, false)
    end
  end

  test "all/4 with send_to option sends data and returns empty (cursor)", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1", "result2"]}>)
    end)

    test_pid = self()
    send_to = fn data -> send(test_pid, {:data, data}) end

    assert {:ok, []} = Paging.all(default_connection(bypass), &Messages.list/2, true, send_to: send_to)
    assert_receive {:data, ["result1", "result2"]}
  end

  test "all/4 with send_to and with_metadata sends tuples (cursor)", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"]}>)
    end)

    test_pid = self()
    send_to = fn data -> send(test_pid, {:data, data}) end

    assert {:ok, []} = Paging.all(default_connection(bypass), &Messages.list/2, true, send_to: send_to, with_metadata: :custom_meta)
    assert_receive {:data, {:custom_meta, ["result1"]}}
  end

  test "all/4 with send_to option sends data and returns empty (offset)", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1", "result2"], "limit": 50, "offset": 0}>)
    end)

    test_pid = self()
    send_to = fn data -> send(test_pid, {:data, data}) end

    assert {:ok, []} = Paging.all(default_connection(bypass), &Messages.list/2, false, send_to: send_to)
    assert_receive {:data, ["result1", "result2"]}
  end

  test "all/4 with send_to and with_metadata sends tuples (offset)", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": ["result1"], "limit": 50, "offset": 0}>)
    end)

    test_pid = self()
    send_to = fn data -> send(test_pid, {:data, data}) end

    assert {:ok, []} = Paging.all(default_connection(bypass), &Messages.list/2, false, send_to: send_to, with_metadata: :page_meta)
    assert_receive {:data, {:page_meta, ["result1"]}}
  end
end
