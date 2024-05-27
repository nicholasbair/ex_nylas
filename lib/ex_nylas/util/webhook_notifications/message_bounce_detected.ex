defmodule ExNylas.WebhookNotification.MessageBounceDetected do
  @moduledoc """
  A struct representing a bounce detected webhook notification.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field :bounce_reason, :string
    field :bounce_date, :string
    field :bounced_address, :string
    field :type, :string
    field :code, :integer

    embeds_one :origin, Origin, primary_key: false do
      field :to, {:array, :string}
      field :from, :string
      field :cc, {:array, :string}
      field :bcc, {:array, :string}
      field :subject, :string
      field :mimeId, :string
      field :id, :string
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:bounce_reason, :bounce_date, :bounced_address, :type, :code])
    |> cast_embed(:origin, with: &embedded_changeset/2)
  end
end
