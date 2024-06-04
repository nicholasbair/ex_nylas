defmodule ExNylas.WebhookNotification.MessageBounceDetected do
  @moduledoc """
  A struct representing a bounce detected webhook notification.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:bounced_address, :string)
    field(:bounce_date, :string)
    field(:bounce_reason, :string)
    field(:code, :integer)
    field(:type, :string)

    embeds_one :origin, Origin, primary_key: false do
      field(:bcc, {:array, :string})
      field(:cc, {:array, :string})
      field(:from, :string)
      field(:id, :string)
      field(:mimeId, :string)
      field(:subject, :string)
      field(:to, {:array, :string})
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:bounce_reason, :bounce_date, :bounced_address, :type, :code])
    |> cast_embed(:origin, with: &embedded_changeset/2)
  end
end
