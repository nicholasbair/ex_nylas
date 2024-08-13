defmodule ExNylas.SmartComposeTest do
  use ExUnit.Case, async: true
  alias ExNylas.{SmartCompose, Response}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "create/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    assert {:ok, %Response{}} = SmartCompose.create(default_connection(bypass), "hello")
  end

  test "create/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %Response{status: :bad_request}} = SmartCompose.create(default_connection(bypass), "hello")
  end

  test "create!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    assert %Response{} = SmartCompose.create!(default_connection(bypass), "hello")
  end

  test "create!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert_raise ExNylasError, fn ->
      SmartCompose.create!(default_connection(bypass), "hello")
    end
  end

  test "create_reply/3 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    message_id = "message-id"
    prompt = "Hello"

    assert {:ok, %Response{}} = SmartCompose.create_reply(default_connection(bypass), message_id, prompt)
  end

  test "create_reply/3 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    message_id = "message-id"
    prompt = "Hello"

    assert {:error, %Response{status: :bad_request}} = SmartCompose.create_reply(default_connection(bypass), message_id, prompt)
  end

  test "create_reply!/3 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    message_id = "message-id"
    prompt = "Hello"

    assert %Response{} = SmartCompose.create_reply!(default_connection(bypass), message_id, prompt)
  end

  test "create_reply!/3 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    message_id = "message-id"
    prompt = "Hello"

    assert_raise ExNylasError, fn ->
      SmartCompose.create_reply!(default_connection(bypass), message_id, prompt)
    end
  end

  test "create_stream/3 streams successfully", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/smart-compose", fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      assert body == ~s<{"prompt":"Write an email"}>

      conn
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)
    end)

    assert {:ok, _} = SmartCompose.create_stream(default_connection(bypass), "Write an email", fn chunk -> chunk end)
  end

  test "create_stream/3 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/smart-compose", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %Response{status: :bad_request}} = SmartCompose.create_stream(default_connection(bypass), "Write an email", fn _ -> :ok end)
  end

  test "create_reply_stream/4 streams successfully", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/message-id/smart-compose", fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      assert body == ~s<{"prompt":"Write an email"}>

      conn
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)
    end)

    assert {:ok, _} = SmartCompose.create_reply_stream(default_connection(bypass), "message-id", "Write an email", fn chunk -> chunk end)
  end

  test "create_reply_stream/4 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/messages/message-id/smart-compose", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %Response{status: :bad_request}} = SmartCompose.create_reply_stream(default_connection(bypass), "message-id", "Write an email", fn _ -> :ok end)
  end
end
