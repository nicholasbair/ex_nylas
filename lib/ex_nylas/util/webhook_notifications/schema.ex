defmodule ExNylas.WebhookNotification do
  @moduledoc """
  A struct representing a webhook notification.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @type t :: %__MODULE__{
          specversion: String.t(),
          type: String.t(),
          source: String.t(),
          id: String.t(),
          time: integer(),
          data: %__MODULE__.Data{
            application_id: String.t(),
            object: map()
          }
        }

  @primary_key false

  embedded_schema do
    field :specversion, :string
    field :type, :string
    field :source, :string
    field :id, :string
    field :time, :integer

    embeds_one :data, Data, primary_key: false do
      field :application_id, :string
      field :object, :map
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:specversion, :type, :source, :id, :time])
    |> cast_embed(:data, with: &embedded_changeset/2)
  end
end
