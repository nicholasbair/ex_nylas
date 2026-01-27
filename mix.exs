defmodule ExNylas.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_nylas,
      version: "0.11.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: "Unofficial Elixir SDK for the Nylas API",
      package: package(),
      deps: deps(),
      name: "ExNylas",
      dialyzer: [plt_add_apps: [:mix]],
      aliases: aliases(),
      source_url: url(),
      homepage_url: url(),
      docs: [
        main: "ExNylas",
        extras: ["README.md", "LICENSE"],
        groups_for_modules: [
          "Admin - API Keys": [
            ExNylas.APIKeys,
            ExNylas.APIKey,
            ExNylas.APIKeys.Build
          ],
          "Admin - Applications": [
            ExNylas.Applications,
            ExNylas.Application,
            ExNylas.Application.Branding,
            ExNylas.Application.HostedAuthentication,
            ExNylas.ApplicationRedirects,
            ExNylas.ApplicationRedirect,
            ExNylas.ApplicationRedirect.Build
          ],
          "Admin - Connector Credentials": [
            ExNylas.ConnectorCredentials,
            ExNylas.ConnectorCredential,
            ExNylas.ConnectorCredential.Build
          ],
          "Admin - Connectors": [
            ExNylas.Connectors,
            ExNylas.Connector,
            ExNylas.Connector.Build,
            ExNylas.Connector.Settings,
            ExNylas.Connector.Build.Settings
          ],
          "Admin - Providers": [
            ExNylas.Providers,
            ExNylas.Provider
          ],
          "Authentication": [
            ExNylas.HostedAuthentication,
            ExNylas.HostedAuthentication.Options,
            ExNylas.HostedAuthentication.Options.Build,
            ExNylas.HostedAuthentication.Error,
            ExNylas.HostedAuthentication.Grant,
            ExNylas.CustomAuthentication,
            ExNylas.CustomAuthentication.Build,
            ExNylas.CustomAuthentication.Build.Settings
          ],
          "Calendar - Availability": [
            ExNylas.Availability,
            ExNylas.Availability.Build,
            ExNylas.Availability.TimeSlot,
            ExNylas.CalendarAvailability,
            ExNylas.CalendarAvailability.Build,
            ExNylas.CalendarAvailability.Build.Participant,
            ExNylas.CalendarAvailability.Build.Participant.OpenHours
          ],
          "Calendar - Calendars": [
            ExNylas.Calendars,
            ExNylas.Calendar,
            ExNylas.Calendar.Build
          ],
          "Calendar - Events": [
            ExNylas.Events,
            ExNylas.Event,
            ExNylas.Event.Build,
            ExNylas.Event.Participant,
            ExNylas.Event.Build.Participant,
            ExNylas.Event.Organizer,
            ExNylas.Event.Conferencing,
            ExNylas.Event.Conferencing.Details,
            ExNylas.Event.Build.Conferencing,
            ExNylas.Event.Build.Conferencing.Details,
            ExNylas.Event.Reminder,
            ExNylas.Event.Build.Reminder
          ],
          "Calendar - Event When": [
            ExNylas.Event.When,
            ExNylas.Event.Date,
            ExNylas.Event.Datespan,
            ExNylas.Event.Timespan,
            ExNylas.Event.Build.When
          ],
          "Calendar - Free/Busy": [
            ExNylas.FreeBusy,
            ExNylas.FreeBusy.Build,
            ExNylas.FreeBusy.TimeSlot,
            ExNylas.CalendarFreeBusy,
            ExNylas.CalendarFreeBusy.Build
          ],
          "Channels": [
            ExNylas.Channels,
            ExNylas.Channel,
            ExNylas.Channel.Build
          ],
          "Common - Availability": [
            ExNylas.AvailabilityRules,
            ExNylas.AvailabilityRules.Build,
            ExNylas.Buffer,
            ExNylas.Buffer.Build,
            ExNylas.OpenHours,
            ExNylas.OpenHours.Build
          ],
          "Common - Email Participants": [
            ExNylas.EmailParticipant,
            ExNylas.EmailParticipant.Build
          ],
          "Common - Event Booking": [
            ExNylas.EventBooking,
            ExNylas.EventBooking.Build
          ],
          "Common - Event Conferencing": [
            ExNylas.EventConferencing,
            ExNylas.EventConferencing.Build,
            ExNylas.EventConferencing.Build.Details,
            ExNylas.EventConferencing.Details
          ],
          "Common - Event Reminder": [
            ExNylas.EventReminder,
            ExNylas.EventReminder.Build
          ],
          "Common - Message Headers": [
            ExNylas.MessageHeader,
            ExNylas.MessageHeader.Build
          ],
          "Common - Scheduling Participants": [
            ExNylas.SchedulingParticipant,
            ExNylas.SchedulingParticipant.Build,
            ExNylas.SchedulingParticipant.Availability,
            ExNylas.SchedulingParticipant.Build.Availability,
            ExNylas.SchedulingParticipant.Booking,
            ExNylas.SchedulingParticipant.Build.Booking
          ],
          "Common - Scheduler": [
            ExNylas.Scheduler,
            ExNylas.Scheduler.Build,
            ExNylas.Scheduler.Build.EmailTemplate,
            ExNylas.Scheduler.Build.EmailTemplate.BookingConfirmed
          ],
          "Common - Tracking Options": [
            ExNylas.TrackingOptions,
            ExNylas.TrackingOptions.Build
          ],
          "Contact Groups": [
            ExNylas.ContactGroups,
            ExNylas.ContactGroup
          ],
          "Contacts": [
            ExNylas.Contacts,
            ExNylas.Contact,
            ExNylas.Contact.Build,
            ExNylas.Contact.Email,
            ExNylas.Contact.Build.Email,
            ExNylas.Contact.PhoneNumber,
            ExNylas.Contact.Build.PhoneNumber,
            ExNylas.Contact.PhysicalAddress,
            ExNylas.Contact.Build.PhysicalAddress,
            ExNylas.Contact.ImAddress,
            ExNylas.Contact.Build.ImAddress,
            ExNylas.Contact.WebPage,
            ExNylas.Contact.Build.WebPage,
            ExNylas.Contact.ContactGroup,
            ExNylas.Contact.Build.ContactGroup
          ],
          "Core": [
            ExNylas.API,
            ExNylas.Auth,
            ExNylas.Connection,
            ExNylas.Multipart,
            ExNylas.ResponseHandler,
            ExNylas.Telemetry,
            ExNylas.Transform
          ],
          "Core - Paging": [
            ExNylas.Paging,
            ExNylas.Paging.Cursor,
            ExNylas.Paging.Helpers,
            ExNylas.Paging.Offset,
            ExNylas.Paging.Options
          ],
          "Core - Response": [
            ExNylas.Response,
            ExNylas.APIError
          ],
          "Email - Attachments": [
            ExNylas.Attachments,
            ExNylas.Attachment,
            ExNylas.Attachment.Build
          ],
          "Email - Drafts": [
            ExNylas.Drafts,
            ExNylas.Draft,
            ExNylas.Draft.Build
          ],
          "Email - Folders": [
            ExNylas.Folders,
            ExNylas.Folder,
            ExNylas.Folder.Build
          ],
          "Email - Message Schedules": [
            ExNylas.MessageSchedules,
            ExNylas.MessageSchedule,
            ExNylas.MessageSchedule.Status
          ],
          "Email - Messages": [
            ExNylas.Messages,
            ExNylas.Message,
            ExNylas.Message.Build
          ],
          "Email - Threads": [
            ExNylas.Threads,
            ExNylas.Thread
          ],
          "Exceptions": [
            ExNylasError
          ],
          "Grants": [
            ExNylas.Grants,
            ExNylas.Grant
          ],
          "Notetaker": [
            ExNylas.Notetakers,
            ExNylas.Notetaker,
            ExNylas.Notetaker.Build,
            ExNylas.Notetaker.Build.MeetingSettings,
            ExNylas.Notetaker.Build.Rules,
            ExNylas.Notetaker.Build.Rules.ParticipantFilter,
            ExNylas.Notetaker.CustomSettings,
            ExNylas.Notetaker.Media,
            ExNylas.Notetaker.Media.Recording,
            ExNylas.Notetaker.Media.Transcript,
            ExNylas.Notetaker.MeetingSettings,
            ExNylas.Notetaker.Rules,
            ExNylas.Notetaker.Rules.ParticipantFilter,
            ExNylas.StandaloneNotetakers
          ],
          "Order Consolidation - Orders": [
            ExNylas.OrderConsolidation.Orders,
            ExNylas.OrderConsolidation.Order,
            ExNylas.OrderConsolidation.Order.Product
          ],
          "Order Consolidation - Shipments": [
            ExNylas.OrderConsolidation.Shipments,
            ExNylas.OrderConsolidation.Shipment,
            ExNylas.OrderConsolidation.Shipment.CarrierEnrichment,
            ExNylas.OrderConsolidation.Shipment.CarrierEnrichment.DeliveryStatus,
            ExNylas.OrderConsolidation.Shipment.CarrierEnrichment.PackageActivity,
            ExNylas.OrderConsolidation.Shipment.CarrierEnrichment.PackageActivity.Location,
            ExNylas.OrderConsolidation.Shipment.CarrierEnrichment.PackageActivity.Status
          ],
          "Room Resources": [
            ExNylas.RoomResources,
            ExNylas.RoomResource
          ],
          "Scheduling - Availability": [
            ExNylas.Scheduling.Availability,
            ExNylas.Scheduling.Availability.Build
          ],
          "Scheduling - Bookings": [
            ExNylas.Scheduling.Bookings,
            ExNylas.Scheduling.Booking,
            ExNylas.Scheduling.Booking.Build,
            ExNylas.Scheduling.Booking.Build.AdditionalGuests,
            ExNylas.Scheduling.Booking.Build.Guest,
            ExNylas.Scheduling.Booking.Organizer
          ],
          "Scheduling - Configurations": [
            ExNylas.Scheduling.Configurations,
            ExNylas.Scheduling.Configuration,
            ExNylas.Scheduling.Configuration.Build,
            ExNylas.Scheduling.Configuration.Availability,
            ExNylas.Scheduling.Configuration.Scheduler,
            ExNylas.Scheduling.Configuration.Scheduler.Build,
            ExNylas.Scheduling.Configuration.Scheduler.EmailTemplate,
            ExNylas.Scheduling.Configuration.Scheduler.EmailTemplate.BookingConfirmed
          ],
          "Scheduling - Sessions": [
            ExNylas.Scheduling.Sessions,
            ExNylas.Scheduling.Session,
            ExNylas.Scheduling.Session.Build
          ],
          "Smart Compose": [
            ExNylas.SmartCompose,
            ExNylas.Schema.SmartCompose
          ],
          "Types": [
            ExNylas.Type.Atom,
            ExNylas.Type.MapOrList
          ],
          "Utilities": [
            ExNylas.Util,
            ExNylas.Util.Error,
            ExNylas.Util.Schema
          ],
          "Webhook Notifications": [
            ExNylas.WebhookNotifications,
            ExNylas.WebhookNotification,
            ExNylas.WebhookNotificationData,
            ExNylas.WebhookNotification.Booking,
            ExNylas.WebhookNotification.Booking.BookingInfo,
            ExNylas.WebhookNotification.Booking.BookingInfo.Participant,
            ExNylas.WebhookNotification.Grant,
            ExNylas.WebhookNotification.MessageBounceDetected,
            ExNylas.WebhookNotification.MessageBounceDetected.Origin,
            ExNylas.WebhookNotification.MessageLinkClicked,
            ExNylas.WebhookNotification.MessageLinkClicked.LinkData,
            ExNylas.WebhookNotification.MessageLinkClicked.Recent,
            ExNylas.WebhookNotification.MessageOpened,
            ExNylas.WebhookNotification.MessageOpened.MessageData,
            ExNylas.WebhookNotification.MessageOpened.Recent,
            ExNylas.WebhookNotification.Notetaker,
            ExNylas.WebhookNotification.Notetaker.Event,
            ExNylas.WebhookNotification.Notetaker.MeetingSettings,
            ExNylas.WebhookNotification.NotetakerMedia,
            ExNylas.WebhookNotification.NotetakerMedia.Media,
            ExNylas.WebhookNotification.Order,
            ExNylas.WebhookNotification.Order.Merchant,
            ExNylas.WebhookNotification.Order.Metadata,
            ExNylas.WebhookNotification.Order.Order,
            ExNylas.WebhookNotification.Order.Order.LineItem,
            ExNylas.WebhookNotification.ThreadReplied,
            ExNylas.WebhookNotification.ThreadReplied.ReplyData,
            ExNylas.WebhookNotification.Tracking,
            ExNylas.WebhookNotification.Tracking.Merchant,
            ExNylas.WebhookNotification.Tracking.Metadata,
            ExNylas.WebhookNotification.Tracking.Shipping
          ],
          "Webhooks": [
            ExNylas.Webhooks,
            ExNylas.Webhook,
            ExNylas.Webhook.Build
          ]
        ],
        groups_for_docs: [
          "API Functions": &(&1[:group] == :api),
          "Build Functions": &(&1[:group] == :build),
          "Schema Functions": &(&1[:group] == :schema)
        ]
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def cli do
    [
      preferred_envs: [quality_check: :test, qc: :test, t: :test],
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      c: "compile",
      qc: "quality_check",
      t: "test"
    ]
  end

  defp deps do
    [
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.12"},
      {:excoveralls, "~> 0.18.1", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:miss, "~> 0.1.5"},
      {:multipart, "~> 0.4.0"},
      {:polymorphic_embed, "~> 5.0"},
      {:req, "~> 0.5.10"},
      {:req_telemetry, "~> 0.1.1"},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false}
    ]
  end

  defp package do
    [
      name: "ex_nylas",
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{url()}/blob/main/CHANGELOG.md",
        "GitHub" => url()
      }
    ]
  end

  defp url, do: "https://github.com/nicholasbair/ex_nylas"
end
