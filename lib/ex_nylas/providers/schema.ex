defmodule ExNylas.Provider do
  @moduledoc """
  Structs for Nylas providers.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          provider: String.t(),
          type: String.t(),
          email_address: String.t(),
          detected: boolean()
        }

  @primary_key false

  embedded_schema do
    field :provider, :string
    field :type, :string
    field :email_address, :string
    field :detected, :boolean
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
