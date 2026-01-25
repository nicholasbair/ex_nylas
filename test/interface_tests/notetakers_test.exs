defmodule ExNylas.NotetakersTest do
  use ExUnit.Case, async: true
  alias ExNylas.{Notetakers, Response, Notetaker}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "cancel/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "DELETE", "/v3/grants/grant_id/notetakers/notetaker-id/cancel", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "notetaker-id"}}>)
    end)

    assert {:ok, %Response{data: %Notetaker{id: "notetaker-id"}}} =
      Notetakers.cancel(default_connection(bypass), "notetaker-id")
  end

  test "cancel/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "DELETE", "/v3/grants/grant_id/notetakers/notetaker-id/cancel", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert {:error, %ExNylas.APIError{status: :not_found}} =
      Notetakers.cancel(default_connection(bypass), "notetaker-id")
  end

  test "cancel!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "DELETE", "/v3/grants/grant_id/notetakers/notetaker-id/cancel", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"id": "notetaker-id"}}>)
    end)

    assert %Response{data: %Notetaker{id: "notetaker-id"}} =
      Notetakers.cancel!(default_connection(bypass), "notetaker-id")
  end

  test "cancel!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, "DELETE", "/v3/grants/grant_id/notetakers/notetaker-id/cancel", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, fn ->
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

    assert {:error, %ExNylas.APIError{status: :not_found}} =
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

    assert_raise ExNylas.APIError, fn ->
      Notetakers.leave!(default_connection(bypass), "notetaker-id")
    end
  end

  test "media/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/grant_id/notetakers/notetaker-id/media", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"recording": {"url": "https://example.com/recording", "size": 12345}, "transcript": {"url": "https://example.com/transcript", "size": 67890}}}>)
    end)

    assert {:ok, %Response{data: %ExNylas.Notetaker.Media{
      recording: %ExNylas.Notetaker.Media.Recording{
        url: "https://example.com/recording",
        size: 12345
      },
      transcript: %ExNylas.Notetaker.Media.Transcript{
        url: "https://example.com/transcript",
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

    assert {:error, %ExNylas.APIError{status: :not_found}} =
      Notetakers.media(default_connection(bypass), "notetaker-id")
  end

  test "media!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/v3/grants/grant_id/notetakers/notetaker-id/media", fn conn ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, ~s<{"data": {"recording": {"url": "https://example.com/recording", "size": 12345}, "transcript": {"url": "https://example.com/transcript", "size": 67890}}}>)
    end)

    assert %Response{data: %ExNylas.Notetaker.Media{
      recording: %ExNylas.Notetaker.Media.Recording{
        url: "https://example.com/recording",
        size: 12345
      },
      transcript: %ExNylas.Notetaker.Media.Transcript{
        url: "https://example.com/transcript",
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

    assert_raise ExNylas.APIError, fn ->
      Notetakers.media!(default_connection(bypass), "notetaker-id")
    end
  end
end
