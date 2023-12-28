defmodule ExNylasTest.WebhookNotification do
  use ExUnit.Case, async: true

  test "valid_signature? raises an error if webhook secret is not included" do
    assert_raise ExNylasError, fn ->
      ExNylas.WebhookNotification.valid_signature?(nil, "", "")
    end
  end

  test "valid_signature? raises an error if body is not a string" do
    assert_raise ExNylasError, fn ->
      ExNylas.WebhookNotification.valid_signature?("1234", %{}, "")
    end
  end

  test "valid_signature? returns false if the signature does not match" do
    assert ExNylas.WebhookNotification.valid_signature?("1234", "", "") == false
  end
end
