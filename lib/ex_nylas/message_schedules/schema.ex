defmodule ExNylas.MessageSchedule do
  @moduledoc """
  A struct for Nylas message schedules.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field :schedule_id, :string
    field :close_time, :integer

    embeds_one :status, Status, primary_key: false do
      field :code, :string
      field :description, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:schedule_id, :close_time])
    |> cast_embed(:status, with: &Util.embedded_changeset/2)
    |> validate_required([:schedule_id])
  end
end
