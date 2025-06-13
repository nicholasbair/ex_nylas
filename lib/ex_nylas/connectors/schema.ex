defmodule ExNylas.Connector do
  @moduledoc """
  A struct representing a Nylas connector.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/connectors-integrations)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud yahoo zoom ews)a)
    field(:scope, {:array, :string})

    embeds_one :settings, Settings, primary_key: false do
      field(:client_id, :string)
      field(:project_id, :string)
      field(:tenant, :string)
      field(:topic_name, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:provider, :scope])
    |> cast_embed(:settings, with: &embedded_changeset/2)
  end
end
