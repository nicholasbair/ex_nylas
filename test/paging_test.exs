defmodule ExNylasTest.Paging do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "all requests the only one page if length of results < limit", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/events", fn conn ->
      Plug.Conn.resp(conn, 200, ~s<[{"id": "1234"}]>)
    end)

    assert {:ok, [%ExNylas.Event{hide_participants: nil, visibility: nil, organizer_name: nil, organizer_email: nil, notifications: nil, metadata: nil, recurrence: nil, conferencing: nil, updated_at: nil, original_start_time: nil, master_event_id: nil, ical_uid: nil, status: nil, busy: nil, when: nil, location: nil, read_only: nil, participants: nil, owner: nil, description: nil, title: nil, message_id: nil, calendar_id: nil, account_id: nil, object: nil, id: "1234"}]} ==
      ExNylas.Connection.new("id", "secret", "token", endpoint_url(bypass.port)) |> ExNylas.Events.all()
  end

  test "all requests next page if length of results == limit", %{bypass: bypass} do
    Bypass.expect(bypass, "GET", "/events", fn conn ->
      Plug.Conn.resp(conn, 200, ~s<[{"id": "1234"}]>)
    end)

    Bypass.expect(bypass, "GET", "/events", fn conn ->
      Plug.Conn.resp(conn, 200, ~s<[]>)
    end)

    ExNylas.Connection.new("id", "secret", "token", endpoint_url(bypass.port)) |> ExNylas.Events.all(%{limit: 1})
  end

  test "all returns an error tuple if it encounters a non-200 HTTP status during paging", %{bypass: bypass} do
    Bypass.expect(bypass, "GET", "/events", fn conn ->
      Plug.Conn.resp(conn, 200, ~s<[{"id": "1234"}]>)
    end)

    Bypass.expect(bypass, "GET", "/events", fn conn ->
      Plug.Conn.resp(conn, 401, ~s<error message>)
    end)

    res = ExNylas.Connection.new("id", "secret", "token", endpoint_url(bypass.port)) |> ExNylas.Events.all(%{limit: 1})

    assert res == {:error, "error message"}
  end


  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
