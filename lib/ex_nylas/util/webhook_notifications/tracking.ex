defmodule ExNylas.WebhookNotification.Tracking do
  @moduledoc """
  Schema for tracking notification.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:confidence_score, :integer) :: non_neg_integer()
    field(:email_category, :string)
    field(:email_timestamp, :integer) :: non_neg_integer()
    field(:error, :string)
    field(:fetched_email_id, :string)
    field(:grant_id, :string)
    field(:object, :string)
    field(:order_status, :string)
    field(:status, :string)

    embeds_one :merchant, Merchant, primary_key: false do
      field(:domain, :string)
      field(:name, :string)
    end

    embeds_one :metadata, Metadata, primary_key: false do
      field(:language, :string)
      field(:market, :string)
      field(:sender_domain, :string)
    end

    embeds_many :shippings, Shipping, primary_key: false do
      field(:carrier, :string)
      field(:decoded_link, :string)
      field(:order_number, :string)
      field(:tracking_link, :string)
      field(:tracking_number, :string)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :confidence_score,
      :email_category,
      :email_timestamp,
      :error,
      :fetched_email_id,
      :grant_id,
      :object,
      :order_status,
      :status
    ])
    |> cast_embed(:merchant, with: &embedded_changeset/2)
    |> cast_embed(:metadata, with: &embedded_changeset/2)
    |> cast_embed(:shippings, with: &embedded_changeset/2)
  end
end
