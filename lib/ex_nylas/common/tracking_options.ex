defmodule ExNylas.TrackingOptions do
  @moduledoc """
  A struct representing tracking options for a message/draft.
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:label, :string)
    field(:links, :boolean)
    field(:opens, :boolean)
    field(:thread_replies, :boolean)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end
end
