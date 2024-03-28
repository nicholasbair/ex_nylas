defmodule ExNylas.Common.Build.EventConferencing do
  @moduledoc """
  Helper module for validating an event conferencing before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:meeting_code, :password, :url, :phone, :pin]}

  # TODO: what about autocreate?

  embedded_schema do
    field :meeting_code, :string
    field :password, :string
    field :url, :string
    field :phone, {:array, :string}
    field :pin, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:meeting_code, :password, :url, :phone, :pin])
  end
end
