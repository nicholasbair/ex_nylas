defmodule ExNylas.Channels do
  @moduledoc """
  Interface for Nylas channels.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/pubsub-notifications)
  """

  use ExNylas,
    object: "channels/pubsub",
    struct: ExNylas.Channel,
    readable_name: "channel",
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :create, :update]

end
