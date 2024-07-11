defmodule ExNylas.Common.Response do
  @moduledoc """
  A struct representing a common response from Nylas.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.{
    Common.Error,
    Type.MapOrList,
    Type.Atom
  }

  @primary_key false

  typed_embedded_schema do
    field(:data, MapOrList)
    field(:next_cursor, :string)
    field(:request_id, :string)
    field(:status, Atom)

    embeds_one :error, Error
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:request_id, :status, :data, :next_cursor])
    |> cast_embed(:error)
  end
end
