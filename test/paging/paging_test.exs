defmodule UtilTest.PagingTest do
  use ExUnit.Case, async: true

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
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        }
      )

    assert match?({:ok, _}, res)
  end

  describe "cursor-based paging" do
    test "pages with cursor when next_cursor is present", %{bypass: bypass} do
      request_count = :counters.new(1, [])

      Bypass.expect(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        count = :counters.get(request_count, 1)
        :counters.add(request_count, 1, 1)
        case count do
          0 ->
            assert conn.params["page_token"] == ""
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}], "next_cursor": "next_page"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          1 ->
            assert conn.params["page_token"] == "next_page"
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "2"}]}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          _ ->
            conn
            |> Plug.Conn.resp(500, ~s<{"error": "unexpected request"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        &ExNylas.Messages.list/2,
        true,
        [query: [limit: 1]]
      )
      assert match?({:ok, data} when is_list(data), res)
      {:ok, data} = res
      assert Enum.any?(data, fn m -> m.id == "1" end)
      assert Enum.any?(data, fn m -> m.id == "2" end)
    end

    test "handles errors during cursor paging", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(500, ~s<{"error": "server error"}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)
      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        &ExNylas.Messages.list/2,
        true,
        [query: [limit: 1]]
      )
      assert match?({:error, _}, res)
    end
  end

  describe "offset-based paging" do
    test "pages with offset when more data is available", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}, {"id": "2"}]}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)
      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        &ExNylas.Messages.list/2,
        false,
        [query: [limit: 50]]
      )
      assert match?({:ok, _}, res)
    end

    test "handles errors during offset paging", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(500, ~s<{"error": "server error"}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)
      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        &ExNylas.Messages.list/2,
        false,
        [query: [limit: 50]]
      )
      assert match?({:error, _}, res)
    end
  end

  describe "send_to functionality" do
    test "sends data to function when send_to is provided", %{bypass: bypass} do
      request_count = :counters.new(1, [])

      send_to_fn = fn data ->
        send(self(), {:data_received, data})
      end

      Bypass.expect(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        count = :counters.get(request_count, 1)
        :counters.add(request_count, 1, 1)
        case count do
          0 ->
            assert conn.params["page_token"] == ""
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}], "next_cursor": "next_page"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          1 ->
            assert conn.params["page_token"] == "next_page"
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "2"}]}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          _ ->
            conn
            |> Plug.Conn.resp(500, ~s<{"error": "unexpected request"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        &ExNylas.Messages.list/2,
        true,
        [send_to: send_to_fn]
      )

      assert match?({:ok, []}, res)
      assert :counters.get(request_count, 1) == 2

      assert_receive {:data_received, [%ExNylas.Message{id: "1"}]}
      assert_receive {:data_received, [%ExNylas.Message{id: "2"}]}
    end

    test "sends data with metadata when both send_to and with_metadata are provided", %{bypass: bypass} do
      request_count = :counters.new(1, [])

      send_to_fn = fn {metadata, data} ->
        send(self(), {:data_received, metadata, data})
      end

      Bypass.expect(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        count = :counters.get(request_count, 1)
        :counters.add(request_count, 1, 1)
        case count do
          0 ->
            assert conn.params["page_token"] == ""
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}], "next_cursor": "next_page"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          1 ->
            assert conn.params["page_token"] == "next_page"
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "2"}]}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          _ ->
            conn
            |> Plug.Conn.resp(500, ~s<{"error": "unexpected request"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        &ExNylas.Messages.list/2,
        true,
        [send_to: send_to_fn, with_metadata: :task_1234]
      )

      assert match?({:ok, []}, res)
      assert :counters.get(request_count, 1) == 2

      assert_receive {:data_received, :task_1234, [%ExNylas.Message{id: "1"}]}
      assert_receive {:data_received, :task_1234, [%ExNylas.Message{id: "2"}]}
    end
  end

  describe "delay functionality" do
    test "respects delay between requests", %{bypass: bypass} do
      delay_ms = 50
      request_count = :counters.new(1, [])

      Bypass.expect(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        count = :counters.get(request_count, 1)
        :counters.add(request_count, 1, 1)
        case count do
          0 ->
            assert conn.params["page_token"] == ""
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}], "next_cursor": "next_page"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          1 ->
            assert conn.params["page_token"] == "next_page"
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "2"}]}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          _ ->
            conn
            |> Plug.Conn.resp(500, ~s<{"error": "unexpected request"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
        end
      end)

      start_time = System.monotonic_time(:millisecond)

      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        &ExNylas.Messages.list/2,
        true,
        [delay: delay_ms]
      )

      end_time = System.monotonic_time(:millisecond)
      duration = end_time - start_time

      assert match?({:ok, _}, res)
      assert :counters.get(request_count, 1) == 2
      assert duration >= delay_ms * 0.8,
        "Expected at least #{delay_ms * 0.8}ms total duration for 2 requests with #{delay_ms}ms delay, got #{duration}ms"
    end
  end

  describe "all! function" do
    test "raises error when all/4 returns error", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(500, ~s<{"error": "server error"}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)
      assert_raise ExNylas.APIError, fn ->
        ExNylas.Paging.all!(
          %ExNylas.Connection{
            grant_id: "1234",
            api_key: "1234",
            api_server: endpoint_url(bypass.port),
            options: [retry: false]
          },
          &ExNylas.Messages.list/2,
          true
        )
      end
    end

    test "returns result when all/4 returns success", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}]}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      res = ExNylas.Paging.all!(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        &ExNylas.Messages.list/2,
        true
      )

      assert is_list(res)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
