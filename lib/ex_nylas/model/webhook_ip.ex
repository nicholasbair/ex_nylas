defmodule ExNylas.Model.WebhookIp do
  @moduledoc """
  A struct for Nylas webhook IP.
  """

  use TypedStruct

  typedstruct do
    field(:ip_addresses, [String.t()])
  end

  def as_struct(), do: struct(__MODULE__)

  def as_list(), do: [as_struct()]
end
