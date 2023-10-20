defmodule ExNylas.Model.Webhook do
  @moduledoc """
  A struct representing a webhook.
  """

  use TypedStruct

  typedstruct do
    field :id, String.t()
    field :description, String.t()
    field :trigger_types, [String.t()]
    field :callback_url, String.t()
    field :status, String.t()
    field :notification_email_addresses, [String.t()]
  end

  def as_struct(), do: struct(__MODULE__)

  def as_list, do: [as_struct()]

  typedstruct module: Build do
    field :description, String.t()
    field :trigger_types, [String.t()]
    field :callback_url, String.t()
    field :notification_email_addresses, [String.t()]
  end
end
