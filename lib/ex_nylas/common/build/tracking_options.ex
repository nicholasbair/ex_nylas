defmodule ExNylas.Common.Build.TrackingOptions do
  @moduledoc """
  A struct representing tracking options for a message/draft.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:links, :opens, :thread_replies, :label]}

  embedded_schema do
    field :links, :boolean
    field :opens, :boolean
    field :thread_replies, :boolean
    field :label, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
