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
end
