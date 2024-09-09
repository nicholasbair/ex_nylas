defmodule ExNylasTest.WebhookNotifications do
  use ExUnit.Case, async: true

  test "validate_signature! raises an error if webhook secret is not included" do
    assert_raise ExNylasError, fn ->
      ExNylas.WebhookNotifications.validate_signature!(nil, "", "")
    end
  end

  test "validate_signature! raises an error if body is not a string" do
    assert_raise ExNylasError, fn ->
      ExNylas.WebhookNotifications.validate_signature!("1234", %{}, "")
    end
  end

  test "validate_signature! returns false if the signature does not match" do
    assert ExNylas.WebhookNotifications.validate_signature!("1234", "", "") == false
  end

  test "validate_signature returns an error if webhook secret is not included" do
    assert {:error, _} = ExNylas.WebhookNotifications.validate_signature(nil, "", "")
  end

  test "validate_signature returns an error if body is not a string" do
    assert {:error, _} = ExNylas.WebhookNotifications.validate_signature("1234", %{}, "")
  end

  test "validate_signature returns an error if signature is not a string" do
    assert {:error, _} = ExNylas.WebhookNotifications.validate_signature("1234", "", nil)
  end

  test "validate_signature returns false if the signature does not match" do
    {:ok, false} = ExNylas.WebhookNotifications.validate_signature("1234", "", "")
  end

  test "to_struct returns an error if the notification type is not recognized" do
    assert {:error, _} = ExNylas.WebhookNotifications.to_struct(bad_webhook_type())
  end

  test "to_struct! raises an error if the notification type is not recognized" do
    assert_raise ExNylasError, fn ->
      ExNylas.WebhookNotifications.to_struct!(bad_webhook_type())
    end
  end

  test "to_struct transforms a raw webhook notification into an ExNylas struct" do
    {:ok, res} = ExNylas.WebhookNotifications.to_struct(good_webhook_type())
    assert res.__struct__ == ExNylas.WebhookNotification
  end

  test "to_struct transforms the child object into the correct struct" do
    {:ok, res} = ExNylas.WebhookNotifications.to_struct(good_webhook_type())
    assert res.data.object.__struct__ == ExNylas.Message
  end

  test "to_struct transforms message.created.truncated into the correct parent type" do
    {:ok, res} =
      good_webhook_type()
      |> Map.put("type", "message.created.truncated")
      |> ExNylas.WebhookNotifications.to_struct()

    assert res.data.object.__struct__ == ExNylas.Message
  end

  test "to_struct transforms message.created.transformed into the correct parent type" do
    {:ok, res} =
      good_webhook_type()
      |> Map.put("type", "message.created.transformed")
      |> ExNylas.WebhookNotifications.to_struct()

    assert res.data.object.__struct__ == ExNylas.Message
  end

  test "to_struct! transforms a raw webhook notification into an ExNylas struct" do
    res = ExNylas.WebhookNotifications.to_struct!(good_webhook_type())
    assert res.__struct__ == ExNylas.WebhookNotification
  end

  test "to_struct! transforms the child object into the correct struct" do
    res = ExNylas.WebhookNotifications.to_struct!(good_webhook_type())
    assert res.data.object.__struct__ == ExNylas.Message
  end

  defp good_webhook_type do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "body" => "<p>mock body</p>",
          "cc" => [
            %{"email" => "cc@nylas.com", "name" => "mock-cc-name"},
            %{"email" => "cc@nylas.com", "name" => "mock-cc-name-2"}
          ],
          "date" => 1_234_567_890,
          "folders" => ["INBOX"],
          "from" => [%{"email" => "from@nylas.com", "name" => "mock-from"}],
          "grant_id" => "mock-grant-id",
          "id" => "mock-id",
          "object" => "message",
          "reply_to_message_id" => "<reply_to_message_id@nylas.com>",
          "snippet" => "mock-snippet",
          "starred" => false,
          "subject" => "mock-subject",
          "thread_id" => "mock-thread-id",
          "to" => [%{"email" => "to@nylas.com", "name" => "mock-to-name"}],
          "unread" => true
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "message.created",
      "webhook_delivery_attempt" => 1
    }
  end

  defp bad_webhook_type do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "body" => "<p>mock body</p>",
          "cc" => [
            %{"email" => "cc@nylas.com", "name" => "mock-cc-name"},
            %{"email" => "cc@nylas.com", "name" => "mock-cc-name-2"}
          ],
          "date" => 1_234_567_890,
          "folders" => ["INBOX"],
          "from" => [%{"email" => "from@nylas.com", "name" => "mock-from"}],
          "grant_id" => "mock-grant-id",
          "id" => "mock-id",
          "object" => "message",
          "reply_to_message_id" => "<reply_to_message_id@nylas.com>",
          "snippet" => "mock-snippet",
          "starred" => false,
          "subject" => "mock-subject",
          "thread_id" => "mock-thread-id",
          "to" => [%{"email" => "to@nylas.com", "name" => "mock-to-name"}],
          "unread" => true
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "foo.bar",
      "webhook_delivery_attempt" => 1
    }
  end
end
