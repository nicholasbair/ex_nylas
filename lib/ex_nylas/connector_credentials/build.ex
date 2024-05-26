defmodule ExNylas.ConnectorCredential.Build do
  @moduledoc """
  Helper module for validating a connector credential before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          credential_type: atom(),
          credential_data: map()
        }

  @derive {Jason.Encoder, only: [:name, :credential_type, :credential_data]}
  @primary_key false

  embedded_schema do
    field :name, :string
    field :credential_type, Ecto.Enum, values: ~w(adminconsent serviceaccount)a
    field :credential_data, :map
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:name, :credential_type, :credential_data])
  end
end
