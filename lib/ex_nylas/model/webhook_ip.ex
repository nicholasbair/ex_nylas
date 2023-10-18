defmodule ExNylas.Model.WebhookIp do
  @moduledoc """
  A struct for Nylas webhook IP.
  """

  use TypedStruct

  typedstruct do
    field(:ip_addresses, [String.t()])
  end
end
