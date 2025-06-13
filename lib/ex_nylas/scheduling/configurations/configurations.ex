defmodule ExNylas.Scheduling.Configurations do
  @moduledoc """
  Interface for Nylas scheduling configurations.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/scheduler/)
  """

  alias ExNylas.Scheduling.Configuration

  use ExNylas,
    object: "scheduling/configurations",
    struct: Configuration,
    readable_name: "scheduling configuration",
    include: [:list, :first, :find, :create, :update, :delete, :build]
end
