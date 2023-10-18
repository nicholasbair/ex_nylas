defmodule ExNylas.Webhooks do
  @moduledoc """
  Interface for Nylas webhook.
  """

  # TODO: add rotate secret, IP addresses, mock payload and test event endpoints

  use ExNylas,
    object: "webhooks",
    struct: ExNylas.Model.Webhook,
    use_admin_url: true,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]
end
