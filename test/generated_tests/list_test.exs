defmodule ExNylasTest.List do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper

  @modules [
    Applications,
    ApplicationRedirects,
    Calendars,
    Channels,
    Connectors,
    ContactGroups,
    Contacts,
    Drafts,
    Events,
    Folders,
    Grants,
    MessageSchedules,
    Messages,
    Notetakers,
    OrderConsolidation.Orders,
    OrderConsolidation.Shipments,
    RoomResources,
    Scheduling.Configurations,
    StandaloneNotetakers,
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
      :list,
      [
        [foo: "bar"]
      ],
      %{
        method: "GET",
        response: ~s<{"data": []}>,
        assert_pattern: {:ok, %ExNylas.Response{data: []}}
      }
    )

    generate_test(
      @module,
      :list!,
      [
        [foo: "bar"]
      ],
      %{
        method: "GET",
        response: ~s<{"data": []}>,
        assert_pattern: %ExNylas.Response{data: []}
      }
    )
  end
end
