defmodule ExNylas.Schema.Connector do
  @moduledoc """
  A struct representing a Nylas connector.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "connector" do
    field :provider, Ecto.Enum, values: ~w(google microsoft imap virtual-calendar icloud)a
    field :settings, :map
    field :scope, {:array, :string}
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:provider])
  end
end
