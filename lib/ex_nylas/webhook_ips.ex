defmodule ExNylas.WebhookIps do
  @moduledoc """
  Interface for Nylas webhook IPs.
  """

  use ExNylas,
    object: "webhooks/ip-addresses",
    struct: ExNylas.Model.WebhookIp,
    use_admin_url: true,
    include: [:list]
end
