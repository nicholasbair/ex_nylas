defmodule ExNylasTest.Calendars do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  use ExNylasTest,
    object: "calendars",
    struct: ExNylas.Calendar,
    include: [:find],
    bypass: bypass
    # include: [:list, :first, :find, :delete, :build, :create, :update, :all]


end
