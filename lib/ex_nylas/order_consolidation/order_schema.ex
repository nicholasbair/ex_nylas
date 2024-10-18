defmodule ExNylas.OrderConsolidation.Order do
  @moduledoc """
  Schema for Nylas order consolidation.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  import ExNylas.Schema.Util, only: [embedded_changeset: 2]

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:application_id, :string)
    field(:object, :string)
    field(:created_at, :integer)
    field(:updated_at, :integer)
    field(:order_id, :string)
    field(:purchase_date, :integer)
    field(:currency, :string)
    field(:merchant_name, :string)
    field(:merchant_domain, :string)
    field(:order_total, :float)
    field(:tax_total, :float)
    field(:discount_total, :float)
    field(:shipping_total, :float)
    field(:gift_card_total, :float)
    field(:order_provider_message_ids, {:array, :string})

    embeds_many :products, Product, primary_key: false do
      field(:name, :string)
      field(:image_url, :string)
      field(:quantity, :integer)
      field(:unit_price, :float)
    end
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :application_id,
      :object,
      :created_at,
      :updated_at,
      :order_id,
      :purchase_date,
      :currency,
      :merchant_name,
      :merchant_domain,
      :order_total,
      :tax_total,
      :discount_total,
      :shipping_total,
      :gift_card_total,
      :order_provider_message_ids
    ])
    |> cast_embed(:products, with: &embedded_changeset/2)
  end
end
