defmodule ExNylasTest.CalendarAvailability do
  use ExUnit.Case, async: true
  alias ExNylas.CalendarAvailability
  import ExNylasTest.Helper, only: [default_connection: 1]

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "calendar availability list" do
    test "calls POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "POST"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      CalendarAvailability.list(default_connection(bypass), %{})
    end

    test "includes the body in the request", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"foo":"bar"}>

        conn
          |> Plug.Conn.resp(200,~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        CalendarAvailability.list(default_connection(bypass), %{foo: "bar"})
    end

    test "returns the ok tuple for success", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(200, ~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        assert {:ok, _} = CalendarAvailability.list(default_connection(bypass), %{})
    end

    test "returns the error tuple for failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        assert {:error, _} = CalendarAvailability.list(default_connection(bypass), %{})
    end
  end

  describe "calendar availability list!" do
    test "calls POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "POST"

        conn
        |> Plug.Conn.resp(200, ~s<{}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      CalendarAvailability.list(default_connection(bypass), %{})
    end

    test "includes the body in the request", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"foo":"bar"}>

        conn
          |> Plug.Conn.resp(200,~s<{}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        CalendarAvailability.list(default_connection(bypass), %{foo: "bar"})
    end

    test "raises an error if a non-success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(400, ~s<{"error": {"type": "bad_request"}}>)
          |> Plug.Conn.put_resp_header("content-type", "application/json")
        end)

        err = "Error: %ExNylas.Response{data: nil, next_cursor: nil, prev_cursor: nil, request_id: nil, status: :bad_request, error: %ExNylas.Error{message: nil, provider_error: nil, type: \"bad_request\"}}"

        assert_raise ExNylasError, err, fn ->
          CalendarAvailability.list!(default_connection(bypass), %{})
        end
    end

    test "does not raise an error if a success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.resp(200, ~s<{"data": []}>)
        |> Plug.Conn.put_resp_header("content-type", "application/json")
      end)

      result = CalendarAvailability.list!(default_connection(bypass), %{})

      assert result == %ExNylas.Response{
        data: [],
        next_cursor: nil,
        request_id: nil,
        status: :ok,
        error: nil
      }
    end
  end
end
