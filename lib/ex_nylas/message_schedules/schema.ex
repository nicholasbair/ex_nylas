defmodule ExNylas.MessageSchedule do
  @moduledoc """
  A struct for Nylas message schedules.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/messages)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  alias ExNylas.Schema.Util

  @primary_key false

  typed_embedded_schema do
    field(:close_time, :integer) :: non_neg_integer() | nil
    field(:schedule_id, :string)

    embeds_one :status, Status, primary_key: false do
      field(:code, :string)
      field(:description, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:schedule_id, :close_time])
    |> cast_embed(:status, with: &Util.embedded_changeset/2)
  end
end
