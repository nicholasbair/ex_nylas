defmodule ExNylasTest.WebhookNotifications do
  use ExUnit.Case, async: true

  describe "signature validation" do
    test "validate_signature! raises an error if webhook secret is not included" do
      assert_raise ExNylas.ValidationError, fn ->
        ExNylas.WebhookNotifications.validate_signature!(nil, "", "")
      end
    end

    test "validate_signature! raises an error if body is not a string" do
      assert_raise ExNylas.ValidationError, fn ->
        ExNylas.WebhookNotifications.validate_signature!("1234", %{}, "")
      end
    end

    test "validate_signature! raises an error if signature is not a string" do
      assert_raise ExNylas.ValidationError, fn ->
        ExNylas.WebhookNotifications.validate_signature!("1234", "", nil)
      end
    end

    test "validate_signature! returns false if the signature does not match" do
      assert ExNylas.WebhookNotifications.validate_signature!("1234", "", "") == false
    end

    test "validate_signature returns an error if webhook secret is not included" do
      assert {:error, "Webhook secret is required for this operation."} =
        ExNylas.WebhookNotifications.validate_signature(nil, "", "")
    end

    test "validate_signature returns an error if body is not a string" do
      assert {:error, "body should be passed as a string."} =
        ExNylas.WebhookNotifications.validate_signature("1234", %{}, "")
    end

    test "validate_signature returns an error if signature is not a string" do
      assert {:error, "signature should be passed as a string."} =
        ExNylas.WebhookNotifications.validate_signature("1234", "", nil)
    end

    test "validate_signature returns false if the signature does not match" do
      assert {:ok, false} = ExNylas.WebhookNotifications.validate_signature("1234", "", "")
    end

    test "validate_signature returns true for valid signature" do
      secret = "test_secret"
      body = "{\"test\": \"data\"}"
      signature = :crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16() |> String.downcase()

      assert {:ok, true} = ExNylas.WebhookNotifications.validate_signature(secret, body, signature)
    end

    test "validate_signature is case insensitive" do
      secret = "test_secret"
      body = "{\"test\": \"data\"}"
      signature = :crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16() |> String.upcase()

      assert {:ok, true} = ExNylas.WebhookNotifications.validate_signature(secret, body, signature)
    end
  end

  describe "webhook notification transformation" do
    test "to_struct returns an error if the notification type is not recognized" do
      assert {:error, _} = ExNylas.WebhookNotifications.to_struct(bad_webhook_type())
    end

    test "to_struct! raises an error if the notification type is not recognized" do
      assert_raise ExNylas.ValidationError, fn ->
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

    test "to_struct transforms message.created.transformed.truncated into the correct parent type" do
      {:ok, res} =
        good_webhook_type()
        |> Map.put("type", "message.created.transformed.truncated")
        |> ExNylas.WebhookNotifications.to_struct()

      assert res.data.object.__struct__ == ExNylas.Message
    end

    test "to_struct handles trigger without suffix modifiers" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(good_webhook_type())

      # Regular message.created (no .truncated or .transformed suffix)
      assert res.data.object.__struct__ == ExNylas.Message
    end

    test "to_struct returns an error tuple given a webhook notification with an unknown child type" do
      res =
        good_webhook_type()
        |> Map.put("type", "message.created.not_a_real_type")
        |> ExNylas.WebhookNotifications.to_struct()

      assert match?({:error, _}, res)
    end

    test "to_struct! transforms a raw webhook notification into an ExNylas struct" do
      res = ExNylas.WebhookNotifications.to_struct!(good_webhook_type())
      assert res.__struct__ == ExNylas.WebhookNotification
    end

    test "to_struct! transforms the child object into the correct struct" do
      res = ExNylas.WebhookNotifications.to_struct!(good_webhook_type())
      assert res.data.object.__struct__ == ExNylas.Message
    end

    test "to_struct handles nil and empty values gracefully" do
      params = %{
        "id" => nil,
        "source" => nil,
        "specversion" => nil,
        "time" => nil,
        "type" => "message.created",
        "webhook_delivery_attempt" => nil,
        "data" => %{
          "application_id" => nil,
          "object" => %{"object" => "message"}
        }
      }

      {:ok, res} = ExNylas.WebhookNotifications.to_struct(params)
      assert res.id == nil
      assert res.source == nil
      assert res.specversion == nil
      assert res.time == nil
      assert res.type == "message.created"
      assert res.webhook_delivery_attempt == nil
      assert res.data.application_id == nil
      assert res.data.object.__struct__ == ExNylas.Message
    end

    test "handles webhook with empty object" do
      webhook = %{
        "data" => %{
          "application_id" => "mock-application-id",
          "object" => %{}
        },
        "id" => "mock-id",
        "source" => "/google/emails/realtime",
        "specversion" => "1.0",
        "time" => 1_234_567_891,
        "type" => "message.created"
      }

      {:ok, res} = ExNylas.WebhookNotifications.to_struct(webhook)
      assert res.data.object.__struct__ == ExNylas.Message
    end

    test "handles webhook with invalid time field" do
      webhook = good_webhook_type() |> Map.put("time", "invalid_time")

      {:error, changeset} = ExNylas.WebhookNotifications.to_struct(webhook)
      refute changeset.valid?
    end

    test "handles webhook with invalid webhook_delivery_attempt field" do
      webhook = good_webhook_type() |> Map.put("webhook_delivery_attempt", -1)

      {:ok, res} = ExNylas.WebhookNotifications.to_struct(webhook)
      assert res.webhook_delivery_attempt == -1
    end
  end

  describe "specific webhook notification types" do
    test "message.opened webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(message_opened_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.MessageOpened
      assert res.data.object.message_id == "msg_123"
      assert res.data.object.label == "opened"
      assert res.data.object.grant_id == "grant_123"
      assert res.data.object.sender_app_id == "app_123"
      assert res.data.object.timestamp == 1234567890

      # Check message_data
      assert res.data.object.message_data.count == 5
      assert res.data.object.message_data.timestamp == 1234567890

      # Check recents
      assert length(res.data.object.recents) == 2
      [recent1, recent2] = res.data.object.recents
      assert recent1.ip == "192.168.1.1"
      assert recent1.opened_id == 1
      assert recent1.timestamp == 1234567890
      assert recent1.user_agent == "Mozilla/5.0"
      assert recent2.ip == "192.168.1.2"
      assert recent2.opened_id == 2
      assert recent2.timestamp == 1234567891
      assert recent2.user_agent == "Chrome/91.0"
    end

    test "booking.created webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(booking_created_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.Booking
      assert res.data.object.configuration_id == "config_123"
      assert res.data.object.booking_id == "booking_123"
      assert res.data.object.booking_ref == "ref_123"
      assert res.data.object.booking_type == "confirmed"

      # Check booking_info
      booking_info = res.data.object.booking_info
      assert booking_info.event_id == "event_123"
      assert booking_info.start_time == 1234567890
      assert booking_info.end_time == 1234567890 + 3600
      assert booking_info.title == "Test Meeting"
      assert booking_info.duration == 60
      assert booking_info.location == "Conference Room A"
      assert booking_info.organizer_timezone == "America/New_York"
      assert booking_info.guest_timezone == "America/Los_Angeles"
      assert booking_info.hide_cancellation_options == false
      assert booking_info.hide_rescheduling_options == false
      assert booking_info.additional_fields == %{"custom_field" => "value"}

      # Check participants
      assert length(booking_info.participants) == 2
      [participant1, participant2] = booking_info.participants
      assert participant1.email == "organizer@example.com"
      assert participant1.name == "Meeting Organizer"
      assert participant2.email == "attendee@example.com"
      assert participant2.name == "Meeting Attendee"
    end

    test "booking.cancelled webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(booking_cancelled_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.Booking
      assert res.data.object.booking_type == "cancelled"
      assert res.data.object.booking_info.cancellation_reason == "User requested cancellation"
    end

    test "booking.rescheduled webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(booking_rescheduled_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.Booking
      assert res.data.object.booking_type == "rescheduled"
      assert res.data.object.booking_info.old_start_time == 1234567890
      assert res.data.object.booking_info.old_end_time == 1234567890 + 3600
      assert res.data.object.booking_info.start_time == 1234567890 + 7200
      assert res.data.object.booking_info.end_time == 1234567890 + 10800
    end

    test "calendar.created webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(calendar_created_webhook())
      assert res.data.object.__struct__ == ExNylas.Calendar
      assert res.data.object.id == "cal_123"
      assert res.data.object.name == "Test Calendar"
      assert res.data.object.description == "A test calendar"
      assert res.data.object.object == "calendar"
    end

    test "event.created webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(event_created_webhook())
      assert res.data.object.__struct__ == ExNylas.Event
      assert res.data.object.id == "event_123"
      assert res.data.object.title == "Test Event"
      assert res.data.object.description == "A test event"
      assert res.data.object.object == "event"
    end

    test "contact.updated webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(contact_updated_webhook())
      assert res.data.object.__struct__ == ExNylas.Contact
      assert res.data.object.id == "contact_123"
      assert res.data.object.given_name == "John"
    end

    test "grant.created webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(grant_created_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.Grant
      assert res.data.object.grant_id == "grant_123"
      assert res.data.object.provider == "gmail"
    end

    test "notetaker.created webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(notetaker_created_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.Notetaker
      assert res.data.object.id == "notetaker_123"
    end

    test "thread.replied webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(thread_replied_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.ThreadReplied
      assert res.data.object.thread_id == "thread_123"
      assert res.data.object.message_id == "msg_123"
    end

    test "message.link.clicked webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(message_link_clicked_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.MessageLinkClicked
      assert res.data.object.message_id == "msg_123"
      assert res.data.object.label == "link_clicked"
      assert res.data.object.grant_id == "grant_123"
      assert res.data.object.sender_app_id == "app_123"
      assert res.data.object.timestamp == 1234567890

      # Check link_data
      assert length(res.data.object.link_data) == 2
      [link1, link2] = res.data.object.link_data
      assert link1.count == 5
      assert link1.url == "https://example.com/link1"
      assert link2.count == 3
      assert link2.url == "https://example.com/link2"

      # Check recents
      assert length(res.data.object.recents) == 1
      [recent] = res.data.object.recents
      assert recent.click_id == 1
      assert recent.ip == "192.168.1.1"
      assert recent.link_index == 0
      assert recent.timestamp == 1234567890
      assert recent.user_agent == "Mozilla/5.0"
    end

    test "message.bounce.detected webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(message_bounce_detected_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.MessageBounceDetected
      assert res.data.object.bounced_address == "bounce@example.com"
      assert res.data.object.bounce_date == "2024-01-15"
      assert res.data.object.bounce_reason == "Mailbox full"
      assert res.data.object.code == "550"
      assert res.data.object.grant_id == "grant_123"
      assert res.data.object.type == "hard"

      # Check origin
      origin = res.data.object.origin
      assert origin.from == "sender@example.com"
      assert origin.id == "msg_123"
      assert origin.subject == "Test Email"
      assert origin.to == ["bounce@example.com"]
      assert origin.cc == ["cc@example.com"]
      assert origin.bcc == ["bcc@example.com"]
    end

    test "notetaker.media webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(notetaker_media_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.NotetakerMedia
      assert res.data.object.id == "notetaker_media_123"
      assert res.data.object.grant_id == "grant_123"
      assert res.data.object.object == "notetaker.media"
      assert res.data.object.state == :available

      # Check media
      media = res.data.object.media
      assert media.recording == "https://example.com/recording.mp4"
      assert media.transcript == "https://example.com/transcript.txt"
    end

    test "tracking webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(tracking_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.Tracking
      assert res.data.object.grant_id == "grant_123"
      assert res.data.object.status == "delivered"

      # Check metadata
      metadata = res.data.object.metadata
      assert metadata.language == "en"

      # Check merchant
      merchant = res.data.object.merchant
      assert merchant.name == "Test Merchant"
      assert merchant.domain == "merchant.com"

      # Check shippings
      assert length(res.data.object.shippings) == 1
      [shipping] = res.data.object.shippings
      assert shipping.carrier == "UPS"
      assert shipping.tracking_link == "https://ups.com/track?num=TRACK123"
    end

    test "order webhook notification" do
      {:ok, res} = ExNylas.WebhookNotifications.to_struct(order_webhook())
      assert res.data.object.__struct__ == ExNylas.WebhookNotification.Order
      assert res.data.object.grant_id == "grant_123"
      assert res.data.object.order_status == "confirmed"

      # Check metadata
      metadata = res.data.object.metadata
      assert metadata.language == "en"

      # Check merchant
      merchant = res.data.object.merchant
      assert merchant.name == "Amazon"
      assert merchant.domain == "amazon.com"

      # Check orders array
      assert length(res.data.object.orders) == 1
      [order] = res.data.object.orders
      assert order.order_date == 1234567890
      assert order.currency == "USD"
    end
  end

  # Helper functions for test data

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

  defp message_opened_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "label" => "opened",
          "grant_id" => "grant_123",
          "message_id" => "msg_123",
          "sender_app_id" => "app_123",
          "timestamp" => 1234567890,
          "message_data" => %{
            "count" => 5,
            "timestamp" => 1234567890
          },
          "recents" => [
            %{
              "ip" => "192.168.1.1",
              "opened_id" => 1,
              "timestamp" => 1234567890,
              "user_agent" => "Mozilla/5.0"
            },
            %{
              "ip" => "192.168.1.2",
              "opened_id" => 2,
              "timestamp" => 1234567891,
              "user_agent" => "Chrome/91.0"
            }
          ]
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "message.opened",
      "webhook_delivery_attempt" => 1
    }
  end

  defp booking_created_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "configuration_id" => "config_123",
          "booking_id" => "booking_123",
          "booking_ref" => "ref_123",
          "booking_type" => "confirmed",
          "booking_info" => %{
            "event_id" => "event_123",
            "start_time" => 1234567890,
            "end_time" => 1234567890 + 3600,
            "title" => "Test Meeting",
            "duration" => 60,
            "location" => "Conference Room A",
            "organizer_timezone" => "America/New_York",
            "guest_timezone" => "America/Los_Angeles",
            "hide_cancellation_options" => false,
            "hide_rescheduling_options" => false,
            "additional_fields" => %{"custom_field" => "value"},
            "participants" => [
              %{"email" => "organizer@example.com", "name" => "Meeting Organizer"},
              %{"email" => "attendee@example.com", "name" => "Meeting Attendee"}
            ]
          }
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "booking.created",
      "webhook_delivery_attempt" => 1
    }
  end

  defp booking_cancelled_webhook do
    booking_created_webhook()
    |> Map.put("type", "booking.cancelled")
    |> put_in(["data", "object", "booking_type"], "cancelled")
    |> put_in(["data", "object", "booking_info", "cancellation_reason"], "User requested cancellation")
  end

  defp booking_rescheduled_webhook do
    booking_created_webhook()
    |> Map.put("type", "booking.rescheduled")
    |> put_in(["data", "object", "booking_type"], "rescheduled")
    |> put_in(["data", "object", "booking_info", "old_start_time"], 1234567890)
    |> put_in(["data", "object", "booking_info", "old_end_time"], 1234567890 + 3600)
    |> put_in(["data", "object", "booking_info", "start_time"], 1234567890 + 7200)
    |> put_in(["data", "object", "booking_info", "end_time"], 1234567890 + 10800)
  end

  defp calendar_created_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "id" => "cal_123",
          "name" => "Test Calendar",
          "description" => "A test calendar",
          "object" => "calendar"
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "calendar.created",
      "webhook_delivery_attempt" => 1
    }
  end

  defp event_created_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "id" => "event_123",
          "title" => "Test Event",
          "description" => "A test event",
          "object" => "event"
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "event.created",
      "webhook_delivery_attempt" => 1
    }
  end

  defp contact_updated_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "id" => "contact_123",
          "given_name" => "John",
          "object" => "contact"
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "contact.updated",
      "webhook_delivery_attempt" => 1
    }
  end

  defp grant_created_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "grant_id" => "grant_123",
          "provider" => "gmail",
          "object" => "grant"
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "grant.created",
      "webhook_delivery_attempt" => 1
    }
  end

  defp notetaker_created_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "id" => "notetaker_123",
          "object" => "notetaker"
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "notetaker.created",
      "webhook_delivery_attempt" => 1
    }
  end

  defp thread_replied_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "thread_id" => "thread_123",
          "message_id" => "msg_123"
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "thread.replied",
      "webhook_delivery_attempt" => 1
    }
  end

  defp message_link_clicked_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "message_id" => "msg_123",
          "label" => "link_clicked",
          "grant_id" => "grant_123",
          "sender_app_id" => "app_123",
          "timestamp" => 1234567890,
          "link_data" => [
            %{"count" => 5, "url" => "https://example.com/link1"},
            %{"count" => 3, "url" => "https://example.com/link2"}
          ],
          "recents" => [
            %{
              "click_id" => 1,
              "ip" => "192.168.1.1",
              "link_index" => 0,
              "timestamp" => 1234567890,
              "user_agent" => "Mozilla/5.0"
            }
          ]
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "message.link_clicked",
      "webhook_delivery_attempt" => 1
    }
  end

  defp message_bounce_detected_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "bounced_address" => "bounce@example.com",
          "bounce_date" => "2024-01-15",
          "bounce_reason" => "Mailbox full",
          "code" => "550",
          "grant_id" => "grant_123",
          "type" => "hard",
          "origin" => %{
            "from" => "sender@example.com",
            "id" => "msg_123",
            "subject" => "Test Email",
            "to" => ["bounce@example.com"],
            "cc" => ["cc@example.com"],
            "bcc" => ["bcc@example.com"]
          }
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "message.bounce_detected",
      "webhook_delivery_attempt" => 1
    }
  end

  defp notetaker_media_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "id" => "notetaker_media_123",
          "grant_id" => "grant_123",
          "object" => "notetaker.media",
          "state" => "available",
          "media" => %{
            "recording" => "https://example.com/recording.mp4",
            "transcript" => "https://example.com/transcript.txt"
          }
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "notetaker.media",
      "webhook_delivery_attempt" => 1
    }
  end

  defp tracking_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "grant_id" => "grant_123",
          "status" => "delivered",
          "metadata" => %{
            "language" => "en"
          },
          "merchant" => %{
            "name" => "Test Merchant",
            "domain" => "merchant.com"
          },
          "shippings" => [
            %{
              "carrier" => "UPS",
              "tracking_link" => "https://ups.com/track?num=TRACK123"
            }
          ]
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "message.intelligence.tracking",
      "webhook_delivery_attempt" => 1
    }
  end

  defp order_webhook do
    %{
      "data" => %{
        "application_id" => "mock-application-id",
        "object" => %{
          "grant_id" => "grant_123",
          "order_status" => "confirmed",
          "metadata" => %{
            "language" => "en"
          },
          "merchant" => %{
            "name" => "Amazon",
            "domain" => "amazon.com"
          },
          "orders" => [
            %{
              "order_date" => 1234567890,
              "currency" => "USD"
            }
          ]
        }
      },
      "id" => "mock-id",
      "source" => "/google/emails/realtime",
      "specversion" => "1.0",
      "time" => 1_234_567_891,
      "type" => "message.intelligence.order",
      "webhook_delivery_attempt" => 1
    }
  end
end
