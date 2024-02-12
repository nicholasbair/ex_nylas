defmodule ExNylas.Schema.Calendar.Availability.Build.Participant do
  @moduledoc """
  Helper module for validating the participant subobject on an availability request.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Schema.Calendar.Availability.Build.OpenHours

  @primary_key false

  schema "participant" do
    field :email, :string
    field :calendar_ids, {:array, :string}
    embeds_many :open_hours, OpenHours
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :calendar_ids])
    |> cast_embed(:open_hours)
  end
end
