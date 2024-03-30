defmodule ExNylas.Scheduling.Configurations do
  @moduledoc """
  Interface for Nylas scheduling configurations.
  """

  alias ExNylas.Scheduling.Configuration

  use ExNylas,
    object: "scheduling/configurations",
    struct: Configuration,
    readable_name: "scheduling configuration",
    include: [:list, :find, :create, :update, :delete, :build],
    use_admin_url: true
end
