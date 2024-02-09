defmodule ExNylas.Schema.CustomAuthentication.Build do
  @moduledoc """
  Structs for Nylas custom authentication.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "custom_authentication" do
    field :provider, :string
    field :settings, :map
    field :state, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:provider, :settings])
  end
end
