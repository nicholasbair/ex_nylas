defmodule ExNylasTest.First do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper

  @modules [
    Calendars,
    Channels,
    Connectors,
    Contacts,
    Drafts,
    Events,
    Folders,
    Grants,
    MessageSchedules,
    Messages,
    RoomResources,
    Scheduling.Configurations,
    Threads,
    Webhooks
  ]

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  for module <- @modules do
    @module module

    generate_test(
      @module,
      :first,
      [
        [foo: "bar"]
      ],
      %{
        method: "GET",
        response: ~s<{"data": []}>,
        assert_pattern: {:ok, %ExNylas.Response{data: %{}}}
      }
    )

    generate_test(
      @module,
      :first!,
      [
        [foo: "bar"]
      ],
      %{
        method: "GET",
        response: ~s<{"data": []}>,
        assert_pattern: %ExNylas.Response{data: %{}}
      }
    )
  end
end
