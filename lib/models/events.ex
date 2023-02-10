defmodule ExNylas.Event do
  @moduledoc """
  A struct representing a event.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A event"
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:calendar_id, String.t())
    field(:message_id, String.t())
    field(:title, String.t())
    field(:description, String.t())
    field(:owner, String.t())
    field(:participants, list())
    field(:read_only, boolean())
    field(:location, String.t())
    field(:when, map())
    field(:start, String.t())
    field(:end, String.t())
    field(:busy, boolean())
    field(:status, String.t())
    field(:ical_uid, String.t())
    field(:master_event_id, String.t())
    field(:original_start_time, non_neg_integer())
  end

  defmodule Build do
    @moduledoc """
    A struct representing a event.
    """
    use TypedStruct

    typedstruct do
      @typedoc "A event"
      field(:calendar_id, String.t(), enforce: true)
      field(:when, map(), enforce: true)
      field(:title, String.t())
      field(:description, String.t())
      field(:location, String.t())
      field(:participants, list())
      field(:busy, boolean())
      field(:recurrance, map())
    end
  end

  defmodule RSVP do
    @moduledoc """
    A struct representing an event RSVP.
    """
    use TypedStruct

    typedstruct do
      @typedoc "An event RSVP"
      field(:id, String.t())
    end
  end

end

defmodule ExNylas.Events do
  @moduledoc """
  Interface for Nylas event.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF
  alias ExNylas.Event.RSVP
  alias ExNylas.Event

  use ExNylas,
    object: "events",
    struct: ExNylas.Event,
    include: [:list, :first, :find, :build]

  @doc """
  Create/update for an event, include `notify_participants` in the params map (optional)

  Example
      {:ok, binary} = conn |> ExNylas.Events.save(`body`)
  """
  def save(%Conn{} = conn, body, params \\ %{}) do
    {method, url} =
      case body.id do
        nil -> {:post, "#{conn.api_server}/events"}
        _ -> {:put, "#{conn.api_server}/events/#{body.id}"}
      end

    res =
      apply(
        API,
        method,
        [url, body, API.header_bearer(conn), [params: params]]
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, Event)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Create/update for an event, include `notify_participants` in the params map (optional)

  Example
      binary = conn |> ExNylas.Events.save!(`body`)
  """
  def save!(%Conn{} = conn, body, params \\ %{}) do
    case save(conn, body, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

  @doc """
  Send an RSVP for a given event, include `notify_participants` in the params map (optional)

  Example
      {:ok, binary} = conn |> ExNylas.Events.rsvp(`body`)
  """
  def rsvp(%Conn{} = conn, body, params \\ %{}) do
    res =
      API.post(
        "#{conn.api_server}/send-rsvp",
        body,
        API.header_bearer(conn),
        params: params
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, RSVP)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Send an RSVP for a given event, include `notify_participants` in the params map (optional)

  Example
      binary = conn |> ExNylas.Events.rsvp!(`body`)
  """
  def rsvp!(%Conn{} = conn, body, params \\ %{}) do
    case rsvp(conn, body, params) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
