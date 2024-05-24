defmodule ExNylas.Connector do
  @moduledoc """
  A struct representing a Nylas connector.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  embedded_schema do
    field :provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud yahoo)a
    field :scope, {:array, :string}

    embeds_one :settings, Settings, primary_key: false do
      field :client_id, :string
      field :project_id, :string
      field :topic_name, :string
      field :tenant, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:provider, :scope])
    |> cast_embed(:settings, with: &embedded_changeset/2)
    |> validate_required([:provider])
  end
end
