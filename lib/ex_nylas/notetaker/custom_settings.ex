defmodule ExNylas.Notetaker.CustomSettings do
  @moduledoc """
  Struct for Notetaker Custom Settings.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/notetaker)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:custom_instructions]}

  typed_embedded_schema do
    field(:custom_instructions, :string)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:custom_instructions])
  end
end
