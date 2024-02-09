defmodule ExNylas.Schema.ApplicationRedirect.Build do
  @moduledoc """
  Helper module for validating an application redirect before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:url, :platform]}
  @primary_key false

  schema "application_redirect" do
    field :url, :string
    field :platform, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :platform])
    |> validate_required([:url, :platform])
  end
end
