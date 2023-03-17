defmodule ExNylasTest do
  # Use async == false to avoid API limits
  use ExUnit.Case, async: false
  doctest ExNylas

  # Stored as strings to avoid additional parsing
  @modules [
    "Account",
    "Application",
    "Calendars",
    "Contacts",
    "Delta",
    "Drafts",
    "Events",
    "Files",
    "Folders",
    "Jobs",
    "Labels",
    "ManagementAccounts",
    "Messages",
    "Threads",
    "Scheduler",
    "Webhooks"
  ]

  defp build_conn do
    %ExNylas.Connection{
      client_id: System.fetch_env!("NYLAS_CLIENT_ID"),
      client_secret: System.fetch_env!("NYLAS_CLIENT_SECRET"),
      access_token: System.fetch_env!("NYLAS_ACCESS_TOKEN")
    }
  end

  # Test for list/2
  @modules
  |> Enum.filter(fn m ->
    Module.concat([ExNylas, String.to_atom(m)])
    |> apply(:__info__, [:functions])
    |> Enum.any?(fn {name, arity} -> name == :list and arity == 2 end)
  end)
  |> Enum.each(fn m ->
    test "List for #{m}" do
      {ok, res} =
        apply(
          Module.concat([ExNylas, String.to_atom(unquote(m))]),
          :list,
          [build_conn(), %{limit: 1}]
        )

      if ok == :error do
        IO.puts("Error on #{unquote(m)}, message printed below")
        IO.inspect(res)
      end

      assert ok == :ok
    end
  end)

  # Test for first/2
  @modules
  |> Enum.filter(fn m ->
    Module.concat([ExNylas, String.to_atom(m)])
    |> apply(:__info__, [:functions])
    |> Enum.any?(fn {name, arity} -> name == :first and arity == 2 end)
  end)
  |> Enum.each(fn m ->
    test "First for #{m}" do
      {ok, res} =
        apply(
          Module.concat([ExNylas, String.to_atom(unquote(m))]),
          :first,
          [build_conn()]
        )

      if ok == :error do
        IO.puts("Error on #{unquote(m)}, message printed below")
        IO.inspect(res)
      end

      assert ok == :ok
    end
  end)
end
