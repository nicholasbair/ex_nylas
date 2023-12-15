defmodule ExNylas.WebhookIPs do
  @moduledoc """
  Interface for Nylas webhook IPs.
  """

  use ExNylas,
    object: "webhooks/ip-addresses",
    struct: ExNylas.Model.WebhookIP,
    readable_name: "webhook IP",
    include: [:list]
end
