defmodule ExNylasTest.Messages do
  use ExUnit.Case, async: true
  alias ExNylas.{Messages, Response, Message}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "send/3 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "message-id"}}>)
    end)

    message = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert {:ok, %Response{data: %Message{id: "message-id"}}} = Messages.send(default_connection(bypass), message, [])
  end

  test "send/3 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    message = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert {:error, %Response{status: :bad_request}} = Messages.send(default_connection(bypass), message, [])
  end

  test "send!/3 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "message-id"}}>)
    end)

    message = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert %Response{data: %Message{id: "message-id"}} = Messages.send!(default_connection(bypass), message, [])
  end

  test "send!/3 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    message = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert_raise ExNylasError, fn ->
      Messages.send!(default_connection(bypass), message, [])
    end
  end

  test "clean/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PUT", "/v3/grants/grant_id/messages/clean", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"id": "cleaned-message-id"}>)
    end)

    assert {:ok, %Response{}} = Messages.clean(default_connection(bypass), %{})
  end

  test "clean/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PUT", "/v3/grants/grant_id/messages/clean", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{"message": "Bad Request"}>)
    end)

    assert {:error, %Response{status: :bad_request}} = Messages.clean(default_connection(bypass), %{})
  end

  test "clean!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PUT", "/v3/grants/grant_id/messages/clean", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"id": "cleaned-message-id", "account_id": "account-id"}>)
    end)

    assert %Response{} = Messages.clean!(default_connection(bypass), %{})
  end

  test "clean!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PUT", "/v3/grants/grant_id/messages/clean", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylasError, fn ->
      Messages.clean!(default_connection(bypass), %{})
    end
  end

  test "send_raw/3 returns success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      assert conn.query_string == "type=mime"
      assert get_req_header(conn, "content-type") |> List.first() |> String.starts_with?("multipart/form-data")

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "raw-message-id"}}>)
    end)

    mime_content = """
    MIME-Version: 1.0
    From: sender@example.com
    To: recipient@example.com
    Subject: Test Raw MIME
    Content-Type: text/plain

    This is a test message sent via raw MIME.
    """

    assert {:ok, %Response{data: %Message{id: "raw-message-id"}}} =
      Messages.send_raw(default_connection(bypass), mime_content)
  end

  test "send_raw/3 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      assert conn.query_string == "type=mime"
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{"error": "Invalid MIME format"}>)
    end)

    mime_content = "Invalid MIME content"

    assert {:error, %Response{status: :bad_request}} =
      Messages.send_raw(default_connection(bypass), mime_content)
  end

  test "send_raw!/3 returns success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      assert conn.query_string == "type=mime"
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "raw-message-id"}}>)
    end)

    mime_content = """
    MIME-Version: 1.0
    From: sender@example.com
    To: recipient@example.com
    Subject: Test Raw MIME
    Content-Type: text/plain

    This is a test message sent via raw MIME.
    """

    assert %Response{data: %Message{id: "raw-message-id"}} =
      Messages.send_raw!(default_connection(bypass), mime_content)
  end

  test "send_raw!/3 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      assert conn.query_string == "type=mime"
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{"error": "Invalid MIME format"}>)
    end)

    mime_content = "Invalid MIME content"

    assert_raise ExNylasError, fn ->
      Messages.send_raw!(default_connection(bypass), mime_content)
    end
  end

  test "send_raw/3 creates proper multipart structure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      assert conn.query_string == "type=mime"

      content_type = get_req_header(conn, "content-type") |> List.first()
      assert String.starts_with?(content_type, "multipart/form-data")

      boundary =
        case Regex.run(~r/boundary=([^;]+)/, content_type) do
          [_, boundary_value] -> String.trim(boundary_value, "\"")
          nil -> flunk("No boundary found in content-type header")
        end

      assert String.length(boundary) > 0

      content_length = get_req_header(conn, "content-length") |> List.first()
      assert content_length
      assert String.to_integer(content_length) > 0

      {:ok, body, _conn} = Plug.Conn.read_body(conn)
      assert String.length(body) > 0

      assert String.contains?(body, "--#{boundary}")
      assert String.contains?(body, "--#{boundary}--")

      assert String.contains?(String.downcase(body), "content-disposition: form-data")

      expected_mime_content = """
      MIME-Version: 1.0
      From: test@example.com
      To: recipient@example.com
      Subject: Test
      Content-Type: text/plain

      Test content
      """
      |> String.trim()

      assert String.contains?(body, expected_mime_content)

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "raw-message-id"}}>)
    end)

    mime_content = """
    MIME-Version: 1.0
    From: test@example.com
    To: recipient@example.com
    Subject: Test
    Content-Type: text/plain

    Test content
    """

    assert {:ok, %Response{data: %Message{id: "raw-message-id"}}} =
      Messages.send_raw(default_connection(bypass), mime_content)
  end

  test "send_raw/3 handles basic MIME content", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/send", fn conn ->
      assert conn.query_string == "type=mime"

      content_type = get_req_header(conn, "content-type") |> List.first()
      assert String.starts_with?(content_type, "multipart/form-data")

      boundary = case Regex.run(~r/boundary=([^;]+)/, content_type) do
        [_, boundary_value] -> String.trim(boundary_value, "\"")
        nil -> flunk("No boundary found in content-type header")
      end
      assert String.length(boundary) > 0

      content_length = get_req_header(conn, "content-length") |> List.first()
      assert content_length
      assert String.to_integer(content_length) > 0

      {:ok, body, _conn} = Plug.Conn.read_body(conn)
      assert String.length(body) > 0

      assert String.contains?(body, "--#{boundary}")
      assert String.contains?(body, "--#{boundary}--")

      assert String.contains?(String.downcase(body), "content-disposition: form-data")

      expected_mime_content = "MIME-Version: 1.0\nSimple MIME content"
      assert String.contains?(body, expected_mime_content)

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "raw-message-id"}}>)
    end)

    mime_content = "MIME-Version: 1.0\nSimple MIME content"

    assert {:ok, %Response{data: %Message{id: "raw-message-id"}}} =
      Messages.send_raw(default_connection(bypass), mime_content)
  end

  test "send/3 returns FileError when attachment file does not exist", %{bypass: bypass} do
    message = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert {:error, %ExNylas.FileError{} = error} = Messages.send(default_connection(bypass), message, ["./nonexistent.txt"])
    assert error.path == "./nonexistent.txt"
    assert error.reason == :enoent
  end

  test "send!/3 raises FileError when attachment file does not exist", %{bypass: bypass} do
    message = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert_raise ExNylas.FileError, ~r/Failed to read file at .*nonexistent\.txt: file does not exist/, fn ->
      Messages.send!(default_connection(bypass), message, ["./nonexistent.txt"])
    end
  end
end
