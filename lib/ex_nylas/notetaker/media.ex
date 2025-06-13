defmodule ExNylas.Notetaker.Media do
  @moduledoc """
  Struct for Notetaker Media.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/notetaker)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    embeds_one :recording, Recording, primary_key: false do
      field(:created_at, :integer)
      field(:expires_at, :integer)
      field(:name, :string)
      field(:size, :integer)
      field(:ttl, :integer)
      field(:type, :string)
      field(:url, :string)
    end

    embeds_one :transcript, Transcript, primary_key: false do
      field(:created_at, :integer)
      field(:expires_at, :integer)
      field(:name, :string)
      field(:size, :integer)
      field(:ttl, :integer)
      field(:type, :string)
      field(:url, :string)
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
