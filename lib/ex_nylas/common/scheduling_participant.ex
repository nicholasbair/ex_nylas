defmodule ExNylas.Common.SchedulingParticipant do
  @moduledoc """
  A struct representing a scheduling participant.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:name, :string)
    field(:email, :string)
    field(:is_organizer, :boolean)

    embeds_one :availability, Availability, primary_key: false do
      field(:calendar_ids, {:array, :string})
    end

    embeds_one :booking, Booking, primary_key: false do
      field(:calendar_id, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :is_organizer])
    |> validate_required([:name, :email])
    |> cast_embed(:booking, with: &embedded_changeset/2)
    |> cast_embed(:availability, with: &embedded_changeset/2)
  end
end
