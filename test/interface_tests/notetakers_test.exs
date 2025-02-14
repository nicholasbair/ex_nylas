defmodule ExNylas.NoteakersTest do
  use ExUnit.Case, async: true
  alias ExNylas.{Notetakers, Response, Notetaker}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "create/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "notetaker-id"}}>)
    end)

    params = %{
      meeting_url: "https://example.com/meeting",
      start_time: 1_234_567_890,
      end_time: 1_234_571_490
    }

    assert {:ok, %Response{data: %Notetaker{id: "notetaker-id"}}} =
      Notetakers.create(default_connection(bypass), params)
  end

  test "create/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    params = %{
      meeting_url: "https://example.com/meeting"
    }

    assert {:error, %Response{status: :bad_request}} =
      Notetakers.create(default_connection(bypass), params)
  end

  test "create!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "notetaker-id"}}>)
    end)

    params = %{
      meeting_url: "https://example.com/meeting",
      start_time: 1_234_567_890,
      end_time: 1_234_571_490
    }

    assert %Response{data: %Notetaker{id: "notetaker-id"}} =
      Notetakers.create!(default_connection(bypass), params)
  end

  test "create!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, ~s<{}>)
    end)

    params = %{
      meeting_url: "https://example.com/meeting"
    }

    assert_raise ExNylasError, fn ->
      Notetakers.create!(default_connection(bypass), params)
    end
  end

  test "cancel/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers/notetaker-id/cancel", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "notetaker-id"}}>)
    end)

    assert {:ok, %Response{data: %Notetaker{id: "notetaker-id"}}} =
      Notetakers.cancel(default_connection(bypass), "notetaker-id")
  end

  test "cancel/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers/notetaker-id/cancel", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert {:error, %Response{status: :not_found}} =
      Notetakers.cancel(default_connection(bypass), "notetaker-id")
  end

  test "cancel!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers/notetaker-id/cancel", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "notetaker-id"}}>)
    end)

    assert %Response{data: %Notetaker{id: "notetaker-id"}} =
      Notetakers.cancel!(default_connection(bypass), "notetaker-id")
  end

  test "cancel!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers/notetaker-id/cancel", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert_raise ExNylasError, fn ->
      Notetakers.cancel!(default_connection(bypass), "notetaker-id")
    end
  end

  test "leave/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers/notetaker-id/leave", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "notetaker-id"}}>)
    end)

    assert {:ok, %Response{data: %Notetaker{id: "notetaker-id"}}} =
      Notetakers.leave(default_connection(bypass), "notetaker-id")
  end

  test "leave/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers/notetaker-id/leave", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert {:error, %Response{status: :not_found}} =
      Notetakers.leave(default_connection(bypass), "notetaker-id")
  end

  test "leave!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers/notetaker-id/leave", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "notetaker-id"}}>)
    end)

    assert %Response{data: %Notetaker{id: "notetaker-id"}} =
      Notetakers.leave!(default_connection(bypass), "notetaker-id")
  end

  test "leave!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v3/grants/grant_id/notetakers/notetaker-id/leave", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert_raise ExNylasError, fn ->
      Notetakers.leave!(default_connection(bypass), "notetaker-id")
    end
  end

  test "media/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/grant_id/notetakers/notetaker-id/media", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"recording": {"url": "https://example.com/recording", "size": 12345}, "transcript": {"text": "Meeting transcript", "size": 67890}}}>)
    end)

    assert {:ok, %Response{data: %ExNylas.Notetaker.Media{
      recording: %ExNylas.Notetaker.Media.Recording{
        url: "https://example.com/recording",
        size: 12345
      },
      transcript: %ExNylas.Notetaker.Media.Transcript{
        text: "Meeting transcript",
        size: 67890
      }
    }}} = Notetakers.media(default_connection(bypass), "notetaker-id")
  end

  test "media/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/grant_id/notetakers/notetaker-id/media", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert {:error, %Response{status: :not_found}} =
      Notetakers.media(default_connection(bypass), "notetaker-id")
  end

  test "media!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/grant_id/notetakers/notetaker-id/media", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"recording": {"url": "https://example.com/recording", "size": 12345}, "transcript": {"text": "Meeting transcript", "size": 67890}}}>)
    end)

    assert %Response{data: %ExNylas.Notetaker.Media{
      recording: %ExNylas.Notetaker.Media.Recording{
        url: "https://example.com/recording",
        size: 12345
      },
      transcript: %ExNylas.Notetaker.Media.Transcript{
        text: "Meeting transcript",
        size: 67890
      }
    }} = Notetakers.media!(default_connection(bypass), "notetaker-id")
  end

  test "media!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/grant_id/notetakers/notetaker-id/media", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert_raise ExNylasError, fn ->
      Notetakers.media!(default_connection(bypass), "notetaker-id")
    end
  end
end
