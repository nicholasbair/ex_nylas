defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/calendars)
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.Notetaker

  @primary_key false

  typed_embedded_schema do
    field(:description, :string)
    field(:grant_id, :string)
    field(:hex_color, :string)
    field(:hex_foreground_color, :string)
    field(:id, :string)
    field(:is_owned_by_user, :boolean)
    field(:is_primary, :boolean)
    field(:location, :string)
    field(:metadata, :map)
    field(:name, :string)
    field(:object, :string)
    field(:read_only, :boolean)
    field(:timezone, :string)

    embeds_one :notetaker, Notetaker
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:description, :grant_id, :hex_color, :hex_foreground_color, :id, :is_owned_by_user, :is_primary, :location, :metadata, :name, :object, :read_only, :timezone])
    |> cast_embed(:notetaker)
  end
end
