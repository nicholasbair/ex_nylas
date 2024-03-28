defmodule ExNylas.SchedulingConfigurations do
  @moduledoc """
  Interface for Nylas scheduling configurations.
  """

  alias ExNylas.SchedulingConfiguration

  use ExNylas,
    object: "scheduling/configurations",
    struct: SchedulingConfiguration,
    readable_name: "scheduling configuration",
    include: [:list, :find, :create, :update, :delete],
    use_admin_url: true
end
