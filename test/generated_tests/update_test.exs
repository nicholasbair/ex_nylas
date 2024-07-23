defmodule ExNylasTest.Update do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper

  @modules [
    Applications,
    ApplicationRedirects,
    Calendars,
    Channels,
    Connectors,
    Contacts,
    Events,
    Folders,
    Messages,
    Scheduling.Bookings,
    Scheduling.Configurations,
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
      :update,
      ["id", %{foo: "bar"}],
      %{
        method: "PATCH",
        response: ~s<{"data": {}}>,
        assert_pattern: {:ok, %ExNylas.Response{data: %{}}}
      }
    )

    generate_test(
      @module,
      :update!,
      ["id", %{foo: "bar"}],
      %{
        method: "PATCH",
        response: ~s<{"data": {}}>,
        assert_pattern: %ExNylas.Response{data: %{}}
      }
    )
  end
end
