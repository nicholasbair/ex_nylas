defmodule ExNylas.Common.AvailabilityRules do
  @moduledoc """
  A struct for availability rules.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ExNylas.Common.{
    Buffer,
    OpenHours
  }

  @type t :: %__MODULE__{
          availability_method: atom(),
          round_robin_group_id: String.t(),
          buffer: Buffer.t(),
          default_open_hours: [OpenHours.t()]
        }

  @primary_key false

  embedded_schema do
    field :availability_method, Ecto.Enum, values: ~w(collective max-fairness max-availability)a
    field :round_robin_group_id, :string

    embeds_one :buffer, Buffer
    embeds_many :default_open_hours, OpenHours
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:availability_method, :round_robin_group_id])
    |> cast_embed(:buffer)
    |> cast_embed(:default_open_hours)
  end
end
