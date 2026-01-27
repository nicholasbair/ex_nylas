defmodule ExNylasTest.Events do
  use ExUnit.Case, async: true
  alias ExNylas.{Events, Response}
  import Plug.Conn
  import ExNylasTest.Helper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "rsvp/4 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{}>)
    end)

    event_id = "event-id"
    status = "accepted"
    calendar_id = "calendar-id"

    assert {:ok, %Response{}} = Events.rsvp(default_connection(bypass), event_id, status, calendar_id)
  end

  test "rsvp/4 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(404, ~s<{}>)
    end)

    event_id = "event-id"
    status = "accepted"
    calendar_id = "calendar-id"

    assert {:error, %ExNylas.Response{status: :not_found}} = Events.rsvp(default_connection(bypass), event_id, status, calendar_id)
  end

  test "rsvp!/4 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{}>)
    end)

    event_id = "event-id"
    status = "accepted"
    calendar_id = "calendar-id"

    assert %Response{} = Events.rsvp!(default_connection(bypass), event_id, status, calendar_id)
  end

  test "rsvp!/4 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(404, ~s<{}>)
    end)

    event_id = "event-id"
    status = "accepted"
    calendar_id = "calendar-id"

    assert_raise ExNylas.APIError, fn ->
      Events.rsvp!(default_connection(bypass), event_id, status, calendar_id)
    end
  end

  test "import_events/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{}>)
    end)

    assert {:ok, %Response{}} = Events.import_events(default_connection(bypass))
  end

  test "import_events/2 returns error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert {:error, %ExNylas.Response{status: :not_found}} = Events.import_events(default_connection(bypass))
  end

  test "import_events!/2 returns success on success", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, ~s<{}>)
    end)

    assert %Response{} = Events.import_events!(default_connection(bypass))
  end

  test "import_events!/2 raises error on failure", %{bypass: bypass} do
    Bypass.expect_once(bypass, fn conn ->
      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(404, ~s<{}>)
    end)

    assert_raise ExNylas.APIError, fn ->
      Events.import_events!(default_connection(bypass))
    end
  end
end
