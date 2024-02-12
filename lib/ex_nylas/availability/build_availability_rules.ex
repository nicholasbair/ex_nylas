defmodule ExNylas.Schema.Calendar.Availability.Build.AvailabilityRules do
  @moduledoc """
  Helper module for validating the availability rules subobject on an availability request.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]
  alias ExNylas.Schema.Calendar.Availability.Build.OpenHours

  @primary_key false
  @derive {Jason.Encoder, only: [:availability_method, :round_robin_group_id, :buffer, :default_open_hours]}

  schema "availability_rules" do
    field :availability_method, Ecto.Enum, values: [:collective, :"max-fairness", :"max-availability"]
    field :round_robin_group_id, :string

    embeds_one :buffer, Buffer, primary_key: false do
      @derive {Jason.Encoder, only: [:before, :after]}

      field :before, :integer
      field :after, :integer
    end

    embeds_many :default_open_hours, OpenHours
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> cast_embed(:buffer, with: &embedded_changeset/2)
    |> cast_embed(:default_open_hours)
  end
end
