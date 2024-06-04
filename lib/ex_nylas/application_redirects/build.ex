defmodule ExNylas.ApplicationRedirect.Build do
  @moduledoc """
  Helper module for validating an application redirect before creating/updating it.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:platform, :url]}
  @primary_key false

  typed_embedded_schema do
    field(:platform, Ecto.Enum, values: ~w(web desktop js ios android)a)
    field(:url, :string, null: false)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:platform, :url])
    |> validate_required([:url])
  end
end
