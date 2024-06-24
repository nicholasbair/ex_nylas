defmodule ExNylas.Channels do
  @moduledoc """
  Interface for Nylas channels.
  """

  use ExNylas,
    object: "channels/pubsub",
    struct: ExNylas.Channel,
    readable_name: "channel",
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :create, :update]

end
