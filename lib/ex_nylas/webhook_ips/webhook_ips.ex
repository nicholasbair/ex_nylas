defmodule ExNylas.WebhookIPs do
  @moduledoc """
  Interface for Nylas webhook IPs.
  """

  use ExNylas,
    object: "webhooks/ip-addresses",
    struct: ExNylas.Schema.WebhookIP,
    readable_name: "webhook IP",
    include: [:list],
    use_admin_url: true
end
