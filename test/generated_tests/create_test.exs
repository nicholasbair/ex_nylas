defmodule ExNylasTest.Create do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper

  @modules [
    ApplicationRedirects,
    Calendars,
    Channels,
    Connectors,
    Contacts,
    Events,
    Folders,
    Notetakers,
    StandaloneNotetakers,
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
      :create,
      [%{foo: "bar"}],
      %{
        method: "POST",
        response: ~s<{"data": {}}>,
        assert_pattern: {:ok, %ExNylas.Response{data: %{}}}
      }
    )

    generate_test(
      @module,
      :create!,
      [%{foo: "bar"}],
      %{
        method: "POST",
        response: ~s<{"data": {}}>,
        assert_pattern: %ExNylas.Response{data: %{}}
      }
    )
  end
end
