defmodule ExNylas.OrderConsolidation.ShipmentTest do
  use ExUnit.Case, async: true
  alias ExNylas.OrderConsolidation.Shipment

  describe "Shipment schema" do
    test "creates a valid shipment with all fields and nested structures" do
      params = %{
        "id" => "shipment_123",
        "grant_id" => "grant_456",
        "application_id" => "app_789",
        "object" => "shipment",
        "created_at" => 1_700_000_000,
        "updated_at" => 1_700_000_100,
        "tracking_provider_message_ids" => ["msg_1", "msg_2"],
        "carrier_name" => "UPS",
        "tracking_number" => "1Z999AA10123456784",
        "tracking_link" => "https://www.ups.com/track?tracknum=1Z999AA10123456784",
        "carrier_enrichment" => %{
          "delivery_date" => 1_700_500_000,
          "delivery_estimate" => 1_700_600_000,
          "service_type" => "Ground",
          "signature_required" => true,
          "delivery_status" => %{
            "description" => "Delivered",
            "carrier_description" => "Package was left at front door"
          },
          "package_activity" => [
            %{
              "carrier_location" => "Distribution Center",
              "timestamp" => 1_700_400_000,
              "status" => %{
                "description" => "In Transit",
                "carrier_description" => "Package is on the way"
              },
              "location" => %{
                "city" => "San Francisco",
                "postal_code" => "94102",
                "state_province_code" => "CA",
                "country_code" => "US",
                "country_name" => "United States"
              }
            }
          ]
        },
        "order" => %{
          "id" => "order_999",
          "order_id" => "ext_order_888"
        }
      }

      changeset = Shipment.changeset(%Shipment{}, params)
      assert changeset.valid?

      shipment = Ecto.Changeset.apply_changes(changeset)
      assert shipment.id == "shipment_123"
      assert shipment.grant_id == "grant_456"
      assert shipment.application_id == "app_789"
      assert shipment.object == "shipment"
      assert shipment.created_at == 1_700_000_000
      assert shipment.updated_at == 1_700_000_100
      assert shipment.tracking_provider_message_ids == ["msg_1", "msg_2"]
      assert shipment.carrier_name == "UPS"
      assert shipment.tracking_number == "1Z999AA10123456784"
      assert shipment.tracking_link == "https://www.ups.com/track?tracknum=1Z999AA10123456784"

      # Test carrier enrichment
      assert shipment.carrier_enrichment.delivery_date == 1_700_500_000
      assert shipment.carrier_enrichment.delivery_estimate == 1_700_600_000
      assert shipment.carrier_enrichment.service_type == "Ground"
      assert shipment.carrier_enrichment.signature_required == true

      # Test delivery status
      assert shipment.carrier_enrichment.delivery_status.description == "Delivered"
      assert shipment.carrier_enrichment.delivery_status.carrier_description == "Package was left at front door"

      # Test package activity
      assert length(shipment.carrier_enrichment.package_activity) == 1
      [activity] = shipment.carrier_enrichment.package_activity
      assert activity.carrier_location == "Distribution Center"
      assert activity.timestamp == 1_700_400_000
      assert activity.status.description == "In Transit"
      assert activity.status.carrier_description == "Package is on the way"
      assert activity.location.city == "San Francisco"
      assert activity.location.postal_code == "94102"
      assert activity.location.state_province_code == "CA"
      assert activity.location.country_code == "US"
      assert activity.location.country_name == "United States"

      # Test embedded order
      assert shipment.order.id == "order_999"
      assert shipment.order.order_id == "ext_order_888"
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "id" => nil,
        "grant_id" => nil,
        "application_id" => nil,
        "object" => nil,
        "created_at" => nil,
        "updated_at" => nil,
        "tracking_provider_message_ids" => nil,
        "carrier_name" => nil,
        "tracking_number" => nil,
        "tracking_link" => nil
      }

      changeset = Shipment.changeset(%Shipment{}, params)
      assert changeset.valid?

      shipment = Ecto.Changeset.apply_changes(changeset)
      assert shipment.id == nil
      assert shipment.grant_id == nil
      assert shipment.application_id == nil
      assert shipment.object == nil
      assert shipment.created_at == nil
      assert shipment.updated_at == nil
      assert shipment.tracking_provider_message_ids == nil
      assert shipment.carrier_name == nil
      assert shipment.tracking_number == nil
      assert shipment.tracking_link == nil
    end

    test "handles shipment without carrier enrichment" do
      params = %{
        "id" => "shipment_456",
        "carrier_name" => "FedEx",
        "tracking_number" => "123456789"
      }

      changeset = Shipment.changeset(%Shipment{}, params)
      assert changeset.valid?

      shipment = Ecto.Changeset.apply_changes(changeset)
      assert shipment.id == "shipment_456"
      assert shipment.carrier_name == "FedEx"
      assert shipment.tracking_number == "123456789"
      assert shipment.carrier_enrichment == nil
    end

    test "handles carrier enrichment without delivery status" do
      params = %{
        "id" => "shipment_789",
        "carrier_enrichment" => %{
          "service_type" => "Express",
          "signature_required" => false
        }
      }

      changeset = Shipment.changeset(%Shipment{}, params)
      assert changeset.valid?

      shipment = Ecto.Changeset.apply_changes(changeset)
      assert shipment.carrier_enrichment.service_type == "Express"
      assert shipment.carrier_enrichment.signature_required == false
      assert shipment.carrier_enrichment.delivery_status == nil
    end

    test "handles empty package activity array" do
      params = %{
        "id" => "shipment_101",
        "carrier_enrichment" => %{
          "service_type" => "Standard",
          "package_activity" => []
        }
      }

      changeset = Shipment.changeset(%Shipment{}, params)
      assert changeset.valid?

      shipment = Ecto.Changeset.apply_changes(changeset)
      assert shipment.carrier_enrichment.package_activity == []
    end

    test "handles multiple package activities" do
      params = %{
        "id" => "shipment_202",
        "carrier_enrichment" => %{
          "package_activity" => [
            %{
              "carrier_location" => "Origin",
              "timestamp" => 1_700_000_000,
              "status" => %{
                "description" => "Picked up"
              }
            },
            %{
              "carrier_location" => "In transit",
              "timestamp" => 1_700_100_000,
              "location" => %{
                "city" => "Los Angeles",
                "state_province_code" => "CA"
              }
            },
            %{
              "carrier_location" => "Destination",
              "timestamp" => 1_700_200_000,
              "status" => %{
                "description" => "Delivered"
              }
            }
          ]
        }
      }

      changeset = Shipment.changeset(%Shipment{}, params)
      assert changeset.valid?

      shipment = Ecto.Changeset.apply_changes(changeset)
      assert length(shipment.carrier_enrichment.package_activity) == 3

      [activity1, activity2, activity3] = shipment.carrier_enrichment.package_activity
      assert activity1.carrier_location == "Origin"
      assert activity1.timestamp == 1_700_000_000
      assert activity1.status.description == "Picked up"

      assert activity2.carrier_location == "In transit"
      assert activity2.timestamp == 1_700_100_000
      assert activity2.location.city == "Los Angeles"
      assert activity2.location.state_province_code == "CA"

      assert activity3.carrier_location == "Destination"
      assert activity3.timestamp == 1_700_200_000
      assert activity3.status.description == "Delivered"
    end

    test "creates minimal shipment with only required tracking fields" do
      params = %{
        "id" => "shipment_minimal",
        "tracking_number" => "TRACK123"
      }

      changeset = Shipment.changeset(%Shipment{}, params)
      assert changeset.valid?

      shipment = Ecto.Changeset.apply_changes(changeset)
      assert shipment.id == "shipment_minimal"
      assert shipment.tracking_number == "TRACK123"
    end
  end
end
