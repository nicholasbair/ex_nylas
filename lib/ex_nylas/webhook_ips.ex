defmodule ExNylas.WebhookIps do
  @moduledoc """
  Interface for Nylas webhook IPs.
  """

  use ExNylas,
    object: "webhooks/ip-addresses",
    struct: ExNylas.Model.WebhookIp,
    readable_name: "webhook IP",
    use_admin_url: true,
    include: [:list]
end
