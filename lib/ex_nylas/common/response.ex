defmodule ExNylas.Common.Response do
  @moduledoc """
  A struct representing a common response from Nylas.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExNylas.{
    Common.Error,
    Type.MapOrList,
    Type.Atom
  }

  @type t :: %__MODULE__{
          request_id: String.t(),
          status: Atom.t(),
          data: MapOrList.t(),
          next_cursor: String.t(),
          error: Error.t()
        }

  @primary_key false

  embedded_schema do
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
