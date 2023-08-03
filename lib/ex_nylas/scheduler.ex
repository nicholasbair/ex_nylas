defmodule ExNylas.Scheduler do
  @moduledoc """
  A struct representing a scheduler page config.
  """
  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  defstruct [
    :access_tokens,
    :access_token_infos,
    :app_client_id,
    :app_organization_id,
    :config,
    :created_at,
    :edit_token,
    :id,
    :modified_at,
    :name,
    :slug,
  ]

  @typedoc "A scheduler page config"
  @type t :: %__MODULE__{
    access_tokens: [String.t()],
    access_token_infos: [ExNylas.Scheduler.AccessTokenInfo.t()],
    app_client_id: String.t(),
    app_organization_id: non_neg_integer(),
    config: ExNylas.Scheduler.Config.t(),
    created_at: String.t(),
    edit_token: String.t(),
    id: non_neg_integer(),
    modified_at: String.t(),
    name: String.t(),
    slug: String.t(),
  }

  defmodule AccessTokenInfo do
    defstruct [
      :account_email,
      :account_name,
    ]

    @type t :: %__MODULE__{
      account_email: String.t(),
      account_name: String.t(),
    }

    def as_struct() do
      %ExNylas.Scheduler.AccessTokenInfo{}
    end
  end

  defmodule Config do
    defstruct [
      :appearance,
      :booking,
      :calendar_ids,
      :disable_emails,
      :event,
      :features,
      :locale,
    ]

    @type t :: %__MODULE__{
      appearance: ExNylas.Scheduler.Appearance.t(),
      booking: ExNylas.Scheduler.Booking.t(),
      calendar_ids: map(),
      disable_emails: boolean(),
      event: ExNylas.Scheduler.Event.t(),
      features: ExNylas.Scheduler.Features.t(),
      locale: String.t(),
    }

    def as_struct() do
      %ExNylas.Scheduler.Config{
        appearance: ExNylas.Scheduler.Appearance.as_struct(),
        booking: ExNylas.Scheduler.Booking.as_struct(),
        event: ExNylas.Scheduler.Event.as_struct(),
        features: ExNylas.Scheduler.Features.as_struct(),
      }
    end
  end

  defmodule Appearance do
    defstruct [
      :color,
      :company_name,
      :logo,
      :show_autoschedule,
      :show_nylas_branding,
      :show_timezone_options,
      :show_week_view,
      :submit_text,
      :thank_you_redirect,
    ]

    @type t :: %__MODULE__{
      color: String.t(),
      company_name: String.t(),
      logo: String.t(),
      show_autoschedule: boolean(),
      show_nylas_branding: boolean(),
      show_timezone_options: boolean(),
      show_week_view: boolean(),
      submit_text: String.t(),
      thank_you_redirect: String.t(),
    }

    def as_struct() do
      %ExNylas.Scheduler.Appearance{}
    end
  end

  defmodule Booking do
    defstruct [
      :additional_fields,
      :additional_guests_hidden,
      :available_days_in_the_future,
      :caledar_invite_to_guests,
      :confirmation_emails_to_guests,
      :confirmation_emails_to_host,
      :confirmation_method,
      :interval_minutes,
      :min_booking_notice,
      :min_buffer,
      :min_cancellation_notice,
      :name_field_hidden,
      :opening_hours,
      :scheduling_method,
    ]

    @type t :: %__MODULE__{
      additional_fields: [ExNylas.Scheduler.AdditionalField.t()],
      additional_guests_hidden: boolean(),
      available_days_in_the_future: non_neg_integer(),
      caledar_invite_to_guests: boolean(),
      confirmation_emails_to_guests: boolean(),
      confirmation_emails_to_host: boolean(),
      confirmation_method: String.t(),
      interval_minutes: non_neg_integer(),
      min_booking_notice: non_neg_integer(),
      min_buffer: non_neg_integer(),
      min_cancellation_notice: non_neg_integer(),
      name_field_hidden: boolean(),
      opening_hours: [ExNylas.Scheduler.OpeningHour.t()],
      scheduling_method: String.t(),
    }

    def as_struct() do
      %ExNylas.Scheduler.Booking{}
    end
  end

  defmodule AdditionalField do
    defstruct [
      :label,
      :name,
      :order,
      :required,
      :type,
      :dropdown_options,
      :multi_select_options,
      :pattern,
    ]

    @type t :: %__MODULE__{
      label: String.t(),
      name: String.t(),
      order: integer(),
      required: boolean(),
      type: String.t(),
      dropdown_options: [String.t()],
      multi_select_options: [String.t()],
      pattern: String.t(),
    }

    def as_struct() do
      %ExNylas.Scheduler.AdditionalField{}
    end
  end

  defmodule OpeningHour do
    defstruct [
      :days,
      :start,
      :end,
    ]

    @type t :: %__MODULE__{
      days: [String.t()],
      start: String.t(),
      end: String.t(),
    }

    def as_struct() do
      %ExNylas.Scheduler.OpeningHour{}
    end
  end

  defmodule Event do
    defstruct [
      :capacity,
      :duration,
      :location,
      :title,
    ]

    @type t :: %__MODULE__{
      capacity: integer(),
      duration: non_neg_integer(),
      location: String.t(),
      title: String.t(),
    }

    def as_struct() do
      %ExNylas.Scheduler.Event{}
    end
  end

  defmodule Features do
    defstruct [
      :collective_meetings,
      :group_meetings,
    ]

    @type t :: %__MODULE__{
      collective_meetings: boolean(),
      group_meetings: boolean(),
    }

    def as_struct() do
      %ExNylas.Scheduler.Features{}
    end
  end

  def as_struct() do
    %ExNylas.Scheduler{
      config: ExNylas.Scheduler.Config.as_struct()
    }
  end

  def as_list(), do: [as_struct()]

  @doc """
  Build a scheduler.

  Note - call create/2 to create the page on Nylas.

  Example
      {:ok, scheduler} = conn |> ExNylas.Scheduler.build(`config`)
  """
  def build(scheduler) do
    try do
      res = build!(scheduler)
      {:ok, res}
    rescue
      e in _ -> {:error, e}
    end
  end

  @doc """
  Build a scheduler.

  Note - call create/2 to create the page on Nylas.

  Example
      scheduler = conn |> ExNylas.Scheduler.build(`config`)
  """
  def build!(scheduler), do: struct!(__MODULE__, scheduler)

  @doc """
  Fetch scheduler pages.

  Example
      {:ok, scheduler_pages} = conn |> ExNylas.Scheduler.list()
  """
  def list(%Conn{} = conn, params \\ %{}) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        API.get(
          url <> "/manage/pages",
          API.header_bearer(conn),
          params: params
        )
        |> API.handle_response(as_list())

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Fetch scheduler pages.

  Example
      scheduler_pages = conn |> ExNylas.Scheduler.list()
  """
  def list!(%Conn{} = conn, params \\ %{}) do
    case list(conn, params) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Fetch the first scheduler page.

  Example
      {:ok, scheduler_page} = conn |> ExNylas.Scheduler.first()
  """
  def first(%Conn{} = conn, params \\ %{}) do
    case list(conn, Map.put(params, :limit, 1)) do
      {:ok, res} -> {:ok, Enum.at(res, 0)}
      res -> res
    end
  end

  @doc """
  Fetch the first page.

  Example
      scheduler_page = conn |> ExNylas.Scheduler.first()
  """
  def first!(%Conn{} = conn, params \\ %{}) do
    case first(conn, params) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Fetch a scheduler page by id.

  Example
      {:ok, scheduler_page} = conn |> ExNylas.Scheduler.find(`id`)
  """
  def find(%Conn{} = conn, id) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        API.get(
          url <> "/manage/pages/#{id}",
          API.header_bearer(conn)
        )
        |> API.handle_response(as_struct())

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Fetch a scheduler page by id.

  Example
      scheduler_page = conn |> ExNylas.Scheduler.find!(`id`)
  """
  def find!(%Conn{} = conn, id) do
    case find(conn, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Delete a scheduler page.

  Example
      {:ok, _} = conn |> ExNylas.Scheduler.delete(`id`)
  """
  def delete(%Conn{} = conn, id) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        API.delete(
          url <> "/manage/pages/#{id}",
          API.header_bearer(conn)
        )
        |> API.handle_response()

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Delete a scheduler page.

  Example
      conn |> ExNylas.Scheduler.delete!(`id`)
  """
  def delete!(%Conn{} = conn, id) do
    case delete(conn, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Create a scheduler page.

  Example
      {:ok, page} = conn |> ExNylas.Scheduler.create(`page_config`)
  """
  def create(%Conn{} = conn, page_config) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        ExNylas.API.post(
          url <> "/manage/pages",
          page_config,
          ExNylas.API.header_bearer(conn) ++ ["content-type": "application/json"]
        )
        |> API.handle_response(as_struct())

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Create a scheduler page.

  Example
      result = conn |> ExNylas.Scheduler.create!(`page_config`)
  """
  def create!(%Conn{} = conn, page_config) do
    case create(conn, page_config) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Update a scheduler page.

  Example
      {:ok, page} = conn |> ExNylas.Scheduler.update(`page_config`, `id`)
  """
  def update(%Conn{} = conn, page_config, id) do
    case convert_to_scheduler_url(conn) do
      {:ok, url} ->
        ExNylas.API.put(
          url <> "/manage/pages/" <> id,
          page_config,
          ExNylas.API.header_bearer(conn) ++ ["content-type": "application/json"]
        )
        |> API.handle_response(as_struct())

      {:error, message} ->
        {:error, message}
    end
  end

  @doc """
  Update a scheduler page.

  Example
      result = conn |> ExNylas.Scheduler.update(`page_config`, `id`)
  """
  def update!(%Conn{} = conn, page_config, id) do
    case update(conn, page_config, id) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  # -- Private --

  defp convert_to_scheduler_url(%Conn{} = conn) do
    case conn.api_server do
      "https://api.nylas.com" -> {:ok, "https://api.schedule.nylas.com"}
      "https://ireland.api.nylas.com" -> {:ok, "https://ireland.api.schedule.nylas.com"}
      _ -> {:error, "No match found for api_server URI"}
    end
  end
end
