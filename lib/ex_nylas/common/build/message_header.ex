defmodule ExNylas.MessageHeader.Build do
  @moduledoc """
  A struct for message header.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:name, :value]}

  typed_embedded_schema do
    field(:name, :string)
    field(:value, :string)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :value])
    |> validate_required([:name, :value])
  end
end
