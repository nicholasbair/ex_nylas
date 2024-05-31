defmodule ExNylas.Connector.Build do
  @moduledoc """
  Helper module for validating a contact before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @derive {Jason.Encoder, only: [:provider, :settings, :scope]}
  @primary_key false

  typed_embedded_schema do
    field(:provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud yahoo)a, null: false)
    field(:scope, {:array, :string})

    embeds_one :settings, Settings, primary_key: false do
      @derive {Jason.Encoder, only: [:client_id, :client_secret, :tenant, :topic_name]}

      field(:client_id, :string)
      field(:client_secret, :string)
      field(:tenant, :string)
      field(:topic_name, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:provider, :scope])
    |> cast_embed(:settings, with: &embedded_changeset/2)
    |> validate_required([:provider])
  end
end
