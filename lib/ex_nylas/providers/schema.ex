defmodule ExNylas.Provider do
  @moduledoc """
  Structs for Nylas providers.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:email_address, :string)
    field(:detected, :boolean)
    field(:provider, Ecto.Enum, values: ~w(google microsoft imap icloud yahoo ews)a)
    field(:type, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
