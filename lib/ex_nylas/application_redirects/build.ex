defmodule ExNylas.ApplicationRedirect.Build do
  @moduledoc """
  Helper module for validating an application redirect before creating/updating it.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:url, :platform]}
  @primary_key false

  embedded_schema do
    field :url, :string
    field :platform, Ecto.Enum, values: [:web, :desktop, :js, :ios, :android]
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :platform])
    |> validate_required([:url])
  end
end
