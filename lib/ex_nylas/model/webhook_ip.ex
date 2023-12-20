defmodule ExNylas.Model.WebhookIP do
  @moduledoc """
  A struct for Nylas webhook IP.
  """

  use TypedStruct

  typedstruct do
    field(:ip_addresses, [String.t()])
    field(:updated_at, non_neg_integer())
  end

  def as_struct, do: struct(__MODULE__)
end
