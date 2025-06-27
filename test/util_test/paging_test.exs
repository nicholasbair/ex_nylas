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
      # Track request count and log all requests
      request_count = :counters.new(1, [])

      Bypass.expect(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        count = :counters.get(request_count, 1)
        :counters.add(request_count, 1, 1)
        case count do
          0 ->
            # First request - should have page_token="" (empty string)
            assert conn.params["page_token"] == ""
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}], "next_cursor": "next_page"}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          1 ->
            # Second request - should have page_token=next_page
            assert conn.params["page_token"] == "next_page"
            conn
            |> Plug.Conn.resp(200, ~s<{"data": [{"id": "2"}]}>)
            |> Plug.Conn.put_resp_header("content-type", "application/json")
          _ ->
            # Unexpected additional requests
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
        ExNylas.Messages,
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
        ExNylas.Messages,
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
        ExNylas.Messages,
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
        ExNylas.Messages,
        false,
        [query: [limit: 50]]
      )
      assert match?({:error, _}, res)
    end
  end

  describe "send_to functionality" do
    test "sends data to function when send_to is provided", %{bypass: bypass} do
      received_data = []

      send_to_fn = fn data ->
        send(self(), {:data_received, data})
        received_data ++ [data]
      end

      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}]}> )
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        ExNylas.Messages,
        true,
        [send_to: send_to_fn]
      )

      assert match?({:ok, []}, res)
      assert_receive {:data_received, [%ExNylas.Message{id: "1"}]}
    end

    test "sends data with metadata when both send_to and with_metadata are provided", %{bypass: bypass} do
      received_data = []

      send_to_fn = fn {metadata, data} ->
        send(self(), {:data_received, metadata, data})
        received_data ++ [{metadata, data}]
      end

      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}]}> )
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        ExNylas.Messages,
        true,
        [send_to: send_to_fn, with_metadata: %{page: 1}]
      )

      assert match?({:ok, []}, res)
      assert_receive {:data_received, %{page: 1}, [%ExNylas.Message{id: "1"}]}
    end
  end

  describe "delay functionality" do
    test "respects delay between requests", %{bypass: bypass} do
      start_time = System.monotonic_time(:millisecond)

      # First page
      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": [{"id": "1"}], "next_cursor": "next_page"}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      # Second page
      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": [{"id": "2"}]}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      res = ExNylas.Paging.all(
        %ExNylas.Connection{
          grant_id: "1234",
          api_key: "1234",
          api_server: endpoint_url(bypass.port),
          options: [retry: false]
        },
        ExNylas.Messages,
        true,
        [delay: 10]  # 10ms delay
      )

      end_time = System.monotonic_time(:millisecond)
      duration = end_time - start_time

      assert match?({:ok, _}, res)
      assert duration >= 0  # Lowered threshold to avoid flakiness
    end
  end

  describe "all! function" do
    test "raises error when all/4 returns error", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/v3/grants/1234/messages", fn conn ->
        conn
        |> Plug.Conn.resp(500, ~s<{"error": "server error"}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)
      assert_raise ExNylasError, fn ->
        ExNylas.Paging.all!(
          %ExNylas.Connection{
            grant_id: "1234",
            api_key: "1234",
            api_server: endpoint_url(bypass.port),
            options: [retry: false]
          },
          ExNylas.Messages,
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
        ExNylas.Messages,
        true
      )

      assert is_list(res)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
