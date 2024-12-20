defmodule ExNylas.EventConferencing do
  @moduledoc """
  A struct representing event conferencing.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:autocreate, :map)
    field(:provider, Ecto.Enum, values: [:"Google Meet", :"Zoom Meeting", :"Microsoft Teams", :"Teams for Business", :"Skype for Consumer", :"Skype for Business"], null: false)

    embeds_one :details, Details, primary_key: false do
      field(:meeting_code, :string)
      field(:password, :string)
      field(:phone, {:array, :string})
      field(:pin, :string)
      field(:url, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:autocreate, :provider])
    |> cast_embed(:details, with: &embedded_changeset/2)
  end
end
