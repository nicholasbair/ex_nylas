defmodule ExNylasTest.WebhookNotification do
  use ExUnit.Case, async: true

  test "valid_signature? raises an error if connection struct lacks `client_secret`" do
    assert_raise ExNylasError, fn ->
      ExNylas.WebhookNotification.valid_signature?(%ExNylas.Connection{}, "", "")
    end
  end

  test "valid_signature? raises an error if body is not a string" do
    assert_raise ExNylasError, fn ->
      ExNylas.WebhookNotification.valid_signature?(%ExNylas.Connection{}, %{}, "")
    end
  end

  test "valid_signature? returns false if the signature does not match" do
    conn = %ExNylas.Connection{client_secret: "1234"}
    assert ExNylas.WebhookNotification.valid_signature?(conn, "", "") == false
  end

  test "valid_signature? returns true if the signature matches" do
    conn = %ExNylas.Connection{client_secret: "1234"}
    body = "{\"deltas\":[{\"type\":\"event.created\",\"object_data\":{\"object\":\"event\",\"namespace_id\":\"czf0dybf2x7hgzgaoqxqv9wir\",\"metadata\":null,\"id\":\"39xz5266jki123xkj7t7qaere\",\"attributes\":{\"created_before_account_connection\":false,\"calendar_id\":\"9a98zjq8c69xkiq6piz27zt4t\"},\"account_id\":\"czf0dybf2x7hgzgaoqxqv9wir\"},\"object\":\"event\",\"date\":1679678365}]}"
    signature = "212087697d7473602f9772af2017ecff0998e0fd35edf17a2c237b4a379693c4"

    assert ExNylas.WebhookNotification.valid_signature?(conn, body, signature) == true
  end
end
