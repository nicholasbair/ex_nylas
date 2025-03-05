defmodule ExNylasTest.Webhooks do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper
  alias ExNylas.Webhooks

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "webhooks update" do
    test "calls PUT", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "PUT"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      Webhooks.update(default_connection(bypass), "id", %{})
    end

    test "includes webhook ID in the path", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PUT", "/v3/webhooks/1234", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      Webhooks.update(default_connection(bypass), "1234", %{})
    end
  end

  describe "webhooks update!" do
    test "raises an error if the response is not successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(400, ~s<{"error": {"type": "bad_request"}}>)
      end)

      assert_raise ExNylasError, ~r/Error: %ExNylas\.Response{.*status: :bad_request.*}/, fn ->
        Webhooks.update!(default_connection(bypass), "id", %{})
      end
    end

    test "returns the common response struct if the response is successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      result = Webhooks.update!(default_connection(bypass), "id", %{})

      assert %ExNylas.Response{
        data: nil,
        next_cursor: nil,
        request_id: nil,
        status: :ok,
        error: nil,
        headers: %{"content-type" => ["application/json"]} = _headers
      } = result
    end
  end

  describe "webhooks rotate secret" do
    test "calls POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "POST"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      Webhooks.rotate_secret(default_connection(bypass), "id")
    end

    test "includes webhook ID in the path", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/v3/webhooks/rotate-secret/1234", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      Webhooks.rotate_secret(default_connection(bypass), "1234")
    end
  end

  describe "webhooks rotate secret!" do
    test "raises an error if the response is not successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(400, ~s<{"error": {"type": "bad_request"}}>)
      end)

      assert_raise ExNylasError, ~r/Error: %ExNylas\.Response{.*status: :bad_request.*}/, fn ->
        Webhooks.rotate_secret!(default_connection(bypass), "id")
      end
    end

    test "returns the common response struct if the response is successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      result = Webhooks.rotate_secret!(default_connection(bypass), "id")

      assert %ExNylas.Response{
        data: nil,
        next_cursor: nil,
        request_id: nil,
        status: :ok,
        error: nil,
        headers: %{"content-type" => ["application/json"]} = _headers
      } = result
    end
  end

  describe "webhooks mock payload" do
    test "calls POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "POST"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      Webhooks.mock_payload(default_connection(bypass), "message.created")
    end

    test "passes the correct request payload", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        assert body == ~s<{"trigger_type":"message.created"}>

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      Webhooks.mock_payload(default_connection(bypass), "message.created")
    end
  end

  describe "webhooks mock payload!" do
    test "raises an error if the response is not successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(400, ~s<{"error": {"type": "bad_request"}}>)
      end)

      assert_raise ExNylasError, ~r/Error: %ExNylas\.Response{.*status: :bad_request.*}/, fn ->
        Webhooks.mock_payload!(default_connection(bypass), "foo.bar")
      end
    end

    test "returns the common response struct if the response is successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      result = Webhooks.mock_payload!(default_connection(bypass), "foo.bar")

      assert %ExNylas.Response{
        data: nil,
        next_cursor: nil,
        request_id: nil,
        status: :ok,
        error: nil,
        headers: %{"content-type" => ["application/json"]} = _headers
      } = result
    end
  end

  describe "webhooks send test notification" do
    test "calls POST", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        assert conn.method == "POST"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      Webhooks.send_test_event(default_connection(bypass), "message.created", "https://example.com/webhooks")
    end
  end

  describe "webhooks send test notification!" do
    test "raises an error if the response is not successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(400, ~s<{"error": {"type": "bad_request"}}>)
      end)

      assert_raise ExNylasError, ~r/Error: %ExNylas\.Response{.*status: :bad_request.*}/, fn ->
        Webhooks.send_test_event!(default_connection(bypass), "foo.bar", "https://example.com/webhooks")
      end
    end

    test "returns the common response struct if the response is successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, ~s<{}>)
      end)

      result = Webhooks.send_test_event!(default_connection(bypass), "foo.bar", "https://example.com/webhooks")

      assert %ExNylas.Response{
        data: nil,
        next_cursor: nil,
        request_id: nil,
        status: :ok,
        error: nil,
        headers: %{"content-type" => ["application/json"]} = _headers
      } = result
    end
  end
end
