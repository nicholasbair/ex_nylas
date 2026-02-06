defmodule ExNylasTest.SchedulingAvailability do
  use ExUnit.Case, async: true
  alias ExNylas.Scheduling.Availability
  import ExNylasTest.Helper, only: [default_connection: 1]

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "scheduling availability get" do
    test "calls GET with correct path", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "//v3/scheduling/availability"

        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      Availability.get(default_connection(bypass), 1614556800, 1614643200)
    end

    test "includes start_time and end_time in query params", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.query_string =~ "start_time=1614556800"
        assert conn.query_string =~ "end_time=1614643200"

        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      Availability.get(default_connection(bypass), 1614556800, 1614643200)
    end

    test "includes config_id in query params when provided", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.query_string =~ "config_id=1234-5678"

        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      Availability.get(default_connection(bypass), 1614556800, 1614643200, config_id: "1234-5678")
    end

    test "includes slug in query params when provided", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.query_string =~ "slug=my-slug"

        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      Availability.get(default_connection(bypass), 1614556800, 1614643200, slug: "my-slug")
    end

    test "includes booking_id in query params when provided", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.query_string =~ "booking_id=booking-123"

        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      Availability.get(default_connection(bypass), 1614556800, 1614643200, booking_id: "booking-123")
    end

    test "uses bearer auth when session_id is provided", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer session-token-123"]

        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      Availability.get(default_connection(bypass), 1614556800, 1614643200, session_id: "session-token-123")
    end

    test "does not use bearer auth when session_id is not provided", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == []

        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      Availability.get(default_connection(bypass), 1614556800, 1614643200)
    end

    test "returns the ok tuple for success", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      assert {:ok, _} = Availability.get(default_connection(bypass), 1614556800, 1614643200)
    end

    test "returns the error tuple for failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(400, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      assert {:error, _} = Availability.get(default_connection(bypass), 1614556800, 1614643200)
    end
  end

  describe "scheduling availability get!" do
    test "calls GET with correct path", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "//v3/scheduling/availability"

        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      Availability.get!(default_connection(bypass), 1614556800, 1614643200)
    end

    test "raises APIError when API returns error response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(400, ~s<{"error": {"type": "bad_request"}}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      assert_raise ExNylas.APIError, fn ->
        Availability.get!(default_connection(bypass), 1614556800, 1614643200)
      end
    end

    test "raises APIError when response has no error struct but failed", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(500, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      assert_raise ExNylas.APIError, ~r/API request failed with status/, fn ->
        Availability.get!(default_connection(bypass), 1614556800, 1614643200)
      end
    end

    test "raises raw exception when error is not a Response", %{bypass: bypass} do
      Bypass.down(bypass)

      assert_raise ExNylas.TransportError, fn ->
        Availability.get!(default_connection(bypass), 1614556800, 1614643200)
      end
    end

    test "does not raise an error if a success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      result = Availability.get!(default_connection(bypass), 1614556800, 1614643200)

      assert %ExNylas.Response{
        data: [],
        next_cursor: nil,
        request_id: nil,
        status: :ok,
        error: nil,
        headers: %{"content-type" => ["application/json"]}
      } = result
    end
  end
end
