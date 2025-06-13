defmodule ExNylas.WebhookNotification.Order do
  @moduledoc """
  Schema for order notification.

  [Nylas docs](https://developer.nylas.com/docs/v3/notifications/notification-schemas/#extractai-notifications)
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
    embeds_one :merchant, Merchant, primary_key: false do
      field(:domain, :string)
      field(:name, :string)
    end
    embeds_one :metadata, Metadata, primary_key: false do
      field(:language, :string)
      field(:market, :string)
      field(:sender_domain, :string)
    end
    field(:object, :string)
    field(:order_status, :string)

    embeds_many :orders, Order, primary_key: false do
      field(:coupon, :string)
      field(:currency, :string)
      field(:discount, :decimal)
      field(:gift_card, :decimal)
      embeds_many :line_items, LineItem, primary_key: false do
        field(:color, :string)
        field(:name, :string)
        field(:product_id, :string)
        field(:product_image_uri, :string)
        field(:quantity, :integer) :: non_neg_integer()
        field(:size, :string)
        field(:unit_price, :decimal)
        field(:url, :string)
      end
      field(:order_date, :integer)
      field(:order_number, :string)
      field(:shipping_total, :decimal)
      field(:total_amount, :decimal)
      field(:total_tax_amount, :decimal)
    end

    field(:status, :string)
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
    |> cast_embed(:orders, with: &order_changeset/2)
  end

  defp order_changeset(struct, params) do
    struct
    |> cast(params, [
      :coupon,
      :currency,
      :discount,
      :gift_card,
      :order_date,
      :order_number,
      :shipping_total,
      :total_amount,
      :total_tax_amount
    ])
    |> cast_embed(:line_items, with: &line_item_changeset/2)
  end

  defp line_item_changeset(struct, params) do
    struct
    |> cast(params, [
      :color,
      :name,
      :product_id,
      :product_image_uri,
      :quantity,
      :size,
      :unit_price,
      :url
    ])
  end
end
