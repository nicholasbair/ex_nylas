defmodule ExNylas.Common.Build.SchedulingParticipant do
  @moduledoc """
  Helper for validating a scheduling participant before sending it.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false
  @derive {Jason.Encoder, only: [:name, :email, :is_organizer, :availability, :booking]}

  typed_embedded_schema do
    field(:email, :string)
    field(:is_organizer, :boolean)
    field(:name, :string)

    embeds_one :availability, Availability, primary_key: false do
      @derive {Jason.Encoder, only: [:calendar_ids]}
      field(:calendar_ids, {:array, :string})
    end

    embeds_one :booking, Booking, primary_key: false do
      @derive {Jason.Encoder, only: [:calendar_id]}
      field(:calendar_id, :string)
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
