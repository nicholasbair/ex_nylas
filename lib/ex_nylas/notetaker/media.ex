defmodule ExNylas.Notetaker.Media do
  @moduledoc """
  Struct for Notetaker Media.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    embeds_one :recording, Recording do
      field(:url, :string)
      field(:size, :integer)
    end

    embeds_one :transcript, Transcript do
      field(:text, :string)
      field(:size, :integer)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> cast_embed(:recording, with: &Util.embedded_changeset/2)
    |> cast_embed(:transcript, with: &Util.embedded_changeset/2)
  end
end
