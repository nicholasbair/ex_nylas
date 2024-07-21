defmodule ExNylasTest.Find do
  use ExUnit.Case, async: true
  import ExNylasTest.Helper

  @modules [
    ApplicationRedirects,
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
      :find,
      ["id"],
      %{
        method: "GET",
        response: ~s<{"data": {}}>,
        assert_pattern: {:ok, %ExNylas.Response{data: %{}}}
      }
    )

    generate_test(
      @module,
      :find!,
      ["id"],
      %{
        method: "GET",
        response: ~s<{"data": {}}>,
        assert_pattern: %ExNylas.Response{data: %{}}
      }
    )
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
