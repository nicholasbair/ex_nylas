defmodule ExNylas.SchedulingSession do
  @moduledoc """
  A struct representing a scheduling session.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :session_id, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:session_id])
    |> validate_required([:session_id])
  end
end
