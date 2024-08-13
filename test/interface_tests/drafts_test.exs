defmodule ExNylas.DraftsTest do
  use ExUnit.Case, async: true
  alias ExNylas.{Drafts, Response, Draft}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "create/3 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/drafts", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "draft-id"}}>)
    end)

    draft = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert {:ok, %Response{data: %Draft{id: "draft-id"}}} = Drafts.create(default_connection(bypass), draft)
  end

  test "create/3 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/drafts", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    draft = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert {:error, %Response{status: :bad_request}} = Drafts.create(default_connection(bypass), draft)
  end

  test "create!/3 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/drafts", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "draft-id", "account_id": "account-id"}}>)
    end)

    draft = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert %Response{data: %Draft{id: "draft-id"}} = Drafts.create!(default_connection(bypass), draft)
  end

  test "create!/3 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/drafts", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    draft = %{
      subject: "Hello",
      body: "Hello world",
      to: [%{email: "recipient@example.com"}]
    }

    assert_raise ExNylasError, fn ->
      Drafts.create!(default_connection(bypass), draft)
    end
  end

  test "update/3 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PATCH", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "updated-draft-id", "subject": "Updated Hello"}}>)
    end)

    changeset = %{
      subject: "Updated Hello",
    }

    assert {:ok, %Response{data: %Draft{id: "updated-draft-id", subject: "Updated Hello"}}} = Drafts.update(default_connection(bypass), "draft-id", changeset)
  end

  test "update/3 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PATCH", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    changeset = %{
      subject: "Updated Hello",
      body: "Updated body"
    }

    assert {:error, %Response{status: :bad_request}} = Drafts.update(default_connection(bypass), "draft-id", changeset)
  end

  test "update!/3 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PATCH", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    changeset = %{
      subject: "Updated Hello",
      body: "Updated body"
    }

    assert %Response{} = Drafts.update!(default_connection(bypass), "draft-id", changeset)
  end

  test "update!/3 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PATCH", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    changeset = %{
      subject: "Updated Hello",
      body: "Updated body"
    }

    assert_raise ExNylasError, fn ->
      Drafts.update!(default_connection(bypass), "draft-id", changeset)
    end
  end

  test "update/4 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PATCH", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    changeset = %{
      subject: "Updated Hello",
      body: "Updated body"
    }

    attachments = ["./test/fixtures/test_attachment.txt"]

    assert {:ok, %Response{}} = Drafts.update(default_connection(bypass), "draft-id", changeset, attachments)
  end

  test "update/4 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PATCH", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    changeset = %{
      subject: "Updated Hello",
      body: "Updated body"
    }

    attachments = ["./test/fixtures/test_attachment.txt"]

    assert {:error, %Response{status: :bad_request}} = Drafts.update(default_connection(bypass), "draft-id", changeset, attachments)
  end

  test "update!/4 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PATCH", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    changeset = %{
      subject: "Updated Hello",
      body: "Updated body"
    }

    attachments = ["./test/fixtures/test_attachment.txt"]

    assert %Response{} = Drafts.update!(default_connection(bypass), "draft-id", changeset, attachments)
  end

  test "update!/4 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PATCH", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    changeset = %{
      subject: "Updated Hello",
      body: "Updated body"
    }

    attachments = ["./test/fixtures/test_attachment.txt"]

    assert_raise ExNylasError, fn ->
      Drafts.update!(default_connection(bypass), "draft-id", changeset, attachments)
    end
  end

  test "send/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    assert {:ok, %Response{}} = Drafts.send(default_connection(bypass), "draft-id")
  end

  test "send/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    assert {:error, %Response{status: :bad_request}} = Drafts.send(default_connection(bypass), "draft-id")
  end

  test "send!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{}>)
    end)

    assert %Response{status: :ok} = Drafts.send!(default_connection(bypass), "draft-id")
  end

  test "send!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/drafts/draft-id", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{"message": "Bad Request"}>)
    end)

    assert_raise ExNylasError, fn ->
      Drafts.send!(default_connection(bypass), "draft-id")
    end
  end
end
