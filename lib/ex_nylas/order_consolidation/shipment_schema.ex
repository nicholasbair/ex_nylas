defmodule ExNylas.OrderConsolidation.Shipment do
  @moduledoc """
  Schema for Nylas order consolidation shipment.
  """

  use TypedEctoSchema
  import Ecto.Changeset
  alias ExNylas.OrderConsolidation.Order

  @primary_key false

  typed_embedded_schema do
    field(:id, :string)
    field(:grant_id, :string)
    field(:application_id, :string)
    field(:object, :string)
    field(:created_at, :integer)
    field(:updated_at, :integer)
    field(:tracking_provider_message_ids, {:array, :string})
    field(:carrier_name, :string)
    field(:tracking_number, :string)
    field(:tracking_link, :string)

    embeds_one :carrier_enrichment, CarrierEnrichment, primary_key: false do
      field(:delivery_date, :integer)
      field(:deliver_estimate, :integer)
      field(:service_type, :string)
      field(:signature_required, :boolean)

      embeds_one :delivery_status, DeliveryStatus, primary_key: false do
        field(:description, :string)
        field(:carrier_description, :string)
      end

      embeds_many :package_activity, PackageActivity, primary_key: false do
        embeds_one :status, Status, primary_key: false do
          field(:description, :string)
          field(:carrier_description, :string)
        end
        embeds_one :location, Location, primary_key: false do
          field(:city, :string)
          field(:postal_code, :string)
          field(:state_province_code, :string)
          field(:country_code, :string)
          field(:country_name, :string)
        end
        field(:carrier_location, :string)
        field(:timestamp, :integer)
      end
    end

    embeds_one :order, Order
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :id,
      :grant_id,
      :application_id,
      :object,
      :created_at,
      :updated_at,
      :tracking_provider_message_ids,
      :carrier_name,
      :tracking_number,
      :tracking_link
    ])
    |> cast_embed(:carrier_enrichment, with: &carrier_enrichment_changeset/2)
    |> cast_embed(:order)
  end

  defp carrier_enrichment_changeset(struct, params) do
    struct
    |> cast(params, [
      :delivery_date,
      :deliver_estimate,
      :service_type,
      :signature_required
    ])
    |> cast_embed(:delivery_status, with: &delivery_status_changeset/2)
    |> cast_embed(:package_activity, with: &package_activity_changeset/2)
  end

  defp delivery_status_changeset(struct, params) do
    struct
    |> cast(params, [
      :description,
      :carrier_description
    ])
  end

  defp package_activity_changeset(struct, params) do
    struct
    |> cast(params, [
      :carrier_location,
      :timestamp
    ])
    |> cast_embed(:status, with: &status_changeset/2)
    |> cast_embed(:location, with: &location_changeset/2)
  end

  defp status_changeset(struct, params) do
    struct
    |> cast(params, [
      :description,
      :carrier_description
    ])
  end

  defp location_changeset(struct, params) do
    struct
    |> cast(params, [
      :city,
      :postal_code,
      :state_province_code,
      :country_code,
      :country_name
    ])
  end
end
