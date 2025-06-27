defmodule ExNylas.OrderConsolidation.OrderTest do
  use ExUnit.Case, async: true
  alias ExNylas.OrderConsolidation.Order

  describe "Order schema" do
    test "creates a valid order with all fields" do
      params = %{
        "id" => "order_123",
        "application_id" => "app_456",
        "object" => "order",
        "created_at" => 1_700_000_000,
        "updated_at" => 1_700_000_100,
        "order_id" => "ext_order_789",
        "purchase_date" => 1_700_000_200,
        "currency" => "USD",
        "merchant_name" => "Amazon",
        "merchant_domain" => "amazon.com",
        "order_total" => "99.99",
        "tax_total" => "8.99",
        "discount_total" => "5.00",
        "shipping_total" => "0.00",
        "gift_card_total" => "0.00",
        "order_provider_message_ids" => ["msg_1", "msg_2"],
        "products" => [
          %{
            "name" => "Product 1",
            "image_url" => "https://example.com/img1.jpg",
            "quantity" => 2,
            "unit_price" => "49.99"
          },
          %{
            "name" => "Product 2",
            "image_url" => "https://example.com/img2.jpg",
            "quantity" => 1,
            "unit_price" => "29.99"
          }
        ]
      }
      changeset = Order.changeset(%Order{}, params)
      assert changeset.valid?
      order = Ecto.Changeset.apply_changes(changeset)
      assert order.id == "order_123"
      assert order.application_id == "app_456"
      assert order.object == "order"
      assert order.created_at == 1_700_000_000
      assert order.updated_at == 1_700_000_100
      assert order.order_id == "ext_order_789"
      assert order.purchase_date == 1_700_000_200
      assert order.currency == "USD"
      assert order.merchant_name == "Amazon"
      assert order.merchant_domain == "amazon.com"
      assert Decimal.eq?(order.order_total, Decimal.new("99.99"))
      assert Decimal.eq?(order.tax_total, Decimal.new("8.99"))
      assert Decimal.eq?(order.discount_total, Decimal.new("5.00"))
      assert Decimal.eq?(order.shipping_total, Decimal.new("0.00"))
      assert Decimal.eq?(order.gift_card_total, Decimal.new("0.00"))
      assert order.order_provider_message_ids == ["msg_1", "msg_2"]
      assert length(order.products) == 2

      [product1, product2] = order.products
      assert product1.name == "Product 1"
      assert product1.image_url == "https://example.com/img1.jpg"
      assert product1.quantity == 2
      assert Decimal.eq?(product1.unit_price, Decimal.new("49.99"))
      assert product2.name == "Product 2"
      assert product2.image_url == "https://example.com/img2.jpg"
      assert product2.quantity == 1
      assert Decimal.eq?(product2.unit_price, Decimal.new("29.99"))
    end

    test "handles nil and empty values for all fields" do
      params = %{
        "id" => nil,
        "application_id" => nil,
        "object" => nil,
        "created_at" => nil,
        "updated_at" => nil,
        "order_id" => nil,
        "purchase_date" => nil,
        "currency" => nil,
        "merchant_name" => nil,
        "merchant_domain" => nil,
        "order_total" => nil,
        "tax_total" => nil,
        "discount_total" => nil,
        "shipping_total" => nil,
        "gift_card_total" => nil,
        "order_provider_message_ids" => nil,
        "products" => []
      }
      changeset = Order.changeset(%Order{}, params)
      assert changeset.valid?
      order = Ecto.Changeset.apply_changes(changeset)
      assert order.id == nil
      assert order.application_id == nil
      assert order.object == nil
      assert order.created_at == nil
      assert order.updated_at == nil
      assert order.order_id == nil
      assert order.purchase_date == nil
      assert order.currency == nil
      assert order.merchant_name == nil
      assert order.merchant_domain == nil
      assert order.order_total == nil
      assert order.tax_total == nil
      assert order.discount_total == nil
      assert order.shipping_total == nil
      assert order.gift_card_total == nil
      assert order.order_provider_message_ids == nil
      assert order.products == []
    end

    test "handles empty arrays" do
      params = %{
        "order_provider_message_ids" => [],
        "products" => []
      }
      changeset = Order.changeset(%Order{}, params)
      assert changeset.valid?
      order = Ecto.Changeset.apply_changes(changeset)
      assert order.order_provider_message_ids == []
      assert order.products == []
    end

    test "handles decimal values with different formats" do
      decimal_values = ["0.00", "10.50", "100.99", "0"]
      for value <- decimal_values do
        params = %{"order_total" => value}
        changeset = Order.changeset(%Order{}, params)
        assert changeset.valid?, "Decimal #{value} should be valid"
        order = Ecto.Changeset.apply_changes(changeset)
        assert Decimal.eq?(order.order_total, Decimal.new(value))
      end
    end

    test "handles integer timestamps and zero values" do
      params = %{
        "created_at" => 0,
        "updated_at" => 0,
        "purchase_date" => 0
      }
      changeset = Order.changeset(%Order{}, params)
      assert changeset.valid?
      order = Ecto.Changeset.apply_changes(changeset)
      assert order.created_at == 0
      assert order.updated_at == 0
      assert order.purchase_date == 0
    end

    test "creates minimal order with only id" do
      params = %{"id" => "order_123"}
      changeset = Order.changeset(%Order{}, params)
      assert changeset.valid?
      order = Ecto.Changeset.apply_changes(changeset)
      assert order.id == "order_123"
    end
  end
end
