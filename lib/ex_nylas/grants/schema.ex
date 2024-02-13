defmodule ExNylas.Grant do
  @moduledoc """
  A struct represting a Nylas grant.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, :string
    field :provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud)a
    field :grant_status, Ecto.Enum, values: ~w(valid invalid)a
    field :email, :string
    field :scope, {:array, :string}
    field :user_agent, :string
    field :ip, :string
    field :state, :string
    field :created_at, :string
    field :updated_at, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:id, :provider, :scope, :grant_status, :scope])
  end
end
