defmodule ExNylas.Common.TrackingOptions do
  @moduledoc """
  A struct representing tracking options for a message/draft.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          links: boolean(),
          opens: boolean(),
          thread_replies: boolean(),
          label: String.t()
        }

  @primary_key false

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
