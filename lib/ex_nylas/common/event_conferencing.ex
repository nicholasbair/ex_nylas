defmodule ExNylas.Common.EventConferencing do
  @moduledoc """
  A struct representing event conferencing.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  embedded_schema do
    field :provider, Ecto.Enum, values: ~w('Google Meet' 'Microsoft Teams')a
    field :autocreate, :map

    embeds_one :details, Details, primary_key: false do
      field :meeting_code, :string
      field :password, :string
      field :url, :string
      field :phone, {:array, :string}
      field :pin, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:autocreate, :provider])
    |> cast_embed(:details, with: &embedded_changeset/2)
  end
end