defmodule ExNylas.Common.SchedulingParticipant do
  @moduledoc """
  A struct representing a scheduling participant.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  # Also used for build schema
  @derive {Jason.Encoder, only: [:name, :email, :is_organizer, :availability, :booking]}

  embedded_schema do
    field :name, :string
    field :email, :string
    field :is_organizer, :boolean

    embeds_one :availability, Availability, primary_key: false do
      @derive {Jason.Encoder, only: [:calendar_ids]}
      field :calendar_ids, {:array, :string}
    end

    embeds_one :booking, Booking, primary_key: false do
      @derive {Jason.Encoder, only: [:calendar_id]}
      field :calendar_id, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :is_organizer])
    |> validate_required([:name, :email])
    |> cast_embed(:booking, with: &embedded_changeset/2)
    |> cast_embed(:availability, with: &embedded_changeset/2)
  end
end