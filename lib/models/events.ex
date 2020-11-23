defmodule ExNylas.Event do
  @moduledoc """
  A struct representing a event.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A event"
    field :id,           String.t()
    field :object,       String.t()
    field :account_id,   String.t()
    field :calendar_id,  String.t()
    field :message_id,   String.t()
    field :title,        String.t()
    field :description,  String.t()
    field :owner,        String.t()
    field :participants, list()
    field :read_only,    boolean()
    field :location,     String.t()
    field :when,         map()
    field :start,        String.t()
    field :end,          String.t()
    field :busy,         boolean()
    field :status,       String.t()
    field :ical_uid,     String.t()
  end

end

defmodule ExNylas.Event.RSVP do
  @moduledoc """
  A struct representing an event RSVP.
  """
  use TypedStruct

  typedstruct do
    @typedoc "An event RSVP"
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

  use ExNylas, object: "events", struct: ExNylas.Event, except: [:search, :send]

  @doc """
  Send an RSVP for a given event

  Example
      {:ok, binary} = conn |> ExNylas.Events.rsvp(`body`)
  """
  def rsvp(%Conn{} = conn, body) do
    res =
      API.post(
        "#{conn.api_server}/send-rsvp",
        API.header_bearer(conn),
        body
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
  Send an RSVP for a given event

  Example
      binary = conn |> ExNylas.Events.rsvp!(`body`)
  """
  def rsvp!(%Conn{} = conn, body) do
    case rsvp(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end

end
