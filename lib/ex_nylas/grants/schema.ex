defmodule ExNylas.Schema.Grant do
  @moduledoc """
  A struct represting a Nylas grant.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "grant" do
    field :id, :string
    field :provider, :string
    field :grant_status, :string
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
    |> validate_required([:id])
  end
end