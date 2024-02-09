defmodule ExNylas.Schema.Common.Response do

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.Schema.{
    Common.Error,
    Type.MapOrList,
    Type.Atom
  }

  @primary_key false

  schema "common" do
    field :request_id, :string
    field :status, Atom
    field :data, MapOrList
    field :next_cursor, :string

    embeds_one :error, Error
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:request_id, :status, :data, :next_cursor])
    |> cast_embed(:error)
  end
end
