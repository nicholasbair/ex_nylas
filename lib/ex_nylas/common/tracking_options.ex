defmodule ExNylas.Common.TrackingOptions do
  @moduledoc """
  A struct representing tracking options for a message/draft.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field :links, :boolean
    field :opens, :boolean
    field :thread_replies, :boolean
    field :label, :string
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, __MODULE__.__schema__(:fields))
  end
end
