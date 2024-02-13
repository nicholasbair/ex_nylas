defmodule ExNylas.CustomAuthentication.Build do
  @moduledoc """
  Helper module for validating a custom authentication request.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud)a
    field :settings, :map
    field :state, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:provider, :settings])
  end
end
