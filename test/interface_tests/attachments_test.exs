defmodule ExNylasTest.Attachments do
  use ExUnit.Case, async: true
  alias ExNylas.Attachments
  import ExNylasTest.Helper, only: [default_connection: 1]

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "attachments download" do
    test "calls GET", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "GET"

        conn
        |> Plug.Conn.resp(200, "abcd")
        |> Plug.Conn.put_resp_header("content-type", "text/plain")
      end)

      Attachments.download(default_connection(bypass), "1234", [message_id: "1234"])
    end

    test "includes the query in the request", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert Enum.any?(conn.params, fn {k, v} -> k == "message_id" and v == "1234" end)

        conn
          |> Plug.Conn.resp(200, "abcd")
          |> Plug.Conn.put_resp_header("content-type", "text/plain")
        end)

        Attachments.download(default_connection(bypass), "1234", [message_id: "1234"])
    end

    test "returns the raw attachment", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(200, "abcd")
          |> Plug.Conn.put_resp_header("content-type", "text/plain")
        end)

        assert {:ok, "abcd"} == Attachments.download(default_connection(bypass), "1234", [message_id: "1234"])
    end
  end

  describe "attachments download!" do
    test "calls GET", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "GET"

        conn
        |> Plug.Conn.resp(200, "abcd")
        |> Plug.Conn.put_resp_header("content-type", "text/plain")
      end)

      Attachments.download!(default_connection(bypass), "1234", [message_id: "1234"])
    end

    test "includes the query in the request", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert Enum.any?(conn.params, fn {k, v} -> k == "message_id" and v == "1234" end)

        conn
          |> Plug.Conn.resp(200, "abcd")
          |> Plug.Conn.put_resp_header("content-type", "text/plain")
        end)

        Attachments.download!(default_connection(bypass), "1234", [message_id: "1234"])
    end

    test "returns the raw attachment", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(200, "abcd")
          |> Plug.Conn.put_resp_header("content-type", "text/plain")
        end)

        assert "abcd" == Attachments.download!(default_connection(bypass), "1234", [message_id: "1234"])
    end

    test "raises an error if a non-success response", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
          |> Plug.Conn.resp(404, "error message")
          |> Plug.Conn.put_resp_header("content-type", "text/plain")
        end)

        assert_raise ExNylas.DecodeError, fn ->
          Attachments.download!(default_connection(bypass), "1234", [message_id: "1234"])
        end
    end
  end
end
