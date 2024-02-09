defmodule ExNylas.Schema.Calendar.Availability.Build do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:participants, :start_time, :end_time, :duration_minutes, :interval_minutes, :round_to_30_minutes, :availability_rules]}
  @primary_key false

  schema "availability" do
    field :participants, {:array, :map}
    field :start_time, :integer
    field :end_time, :integer
    field :duration_minutes, :integer
    field :interval_minutes, :integer
    field :round_to_30_minutes, :boolean
    field :availability_rules, {:array, :map}
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
    |> validate_required([:participants, :start_time, :end_time, :duration_minutes, :interval_minutes, :round_to_30_minutes, :availability_rules])
  end
end
