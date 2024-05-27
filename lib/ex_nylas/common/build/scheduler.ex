defmodule ExNylas.Common.Build.Scheduler do
  @moduledoc """
  Helper module for validating a scheduler configuration before sending it.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:available_days_in_future, :min_cancellation_notice, :rescheduling_url, :cancellation_url]}

  typed_embedded_schema do
    field :available_days_in_future, :integer
    field :min_cancellation_notice, :integer
    field :rescheduling_url, :string
    field :cancellation_url, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:available_days_in_future, :min_cancellation_notice, :rescheduling_url, :cancellation_url])
  end
end
