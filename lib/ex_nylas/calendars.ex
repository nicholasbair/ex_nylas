defmodule ExNylas.Calendar do
  @moduledoc """
  A struct representing a calendar.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A calendar"
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:name, String.t())
    field(:description, String.t())
    field(:read_only, boolean())
    field(:location, String.t())
    field(:timezone, String.t())
    field(:metadata, map())
    field(:is_primary, boolean())
    field(:hex_color, String.t())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the create calendar request payload."
    field(:name, String.t(), enforce: true)
    field(:description, String.t())
    field(:location, String.t())
    field(:timezone, String.t())
  end

  typedstruct module: Availability do
    @typedoc "Calendar availability"
    field(:object, String.t())
    field(:timeslots, list())
  end
end

defmodule ExNylas.Calendars do
  @moduledoc """
  Interface for Nylas calendars.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Calendar.Availability

  use ExNylas,
    object: "calendars",
    struct: ExNylas.Calendar,
    include: [:list, :first, :find, :delete, :build, :create, :update, :all]

  @doc """
  Get calendar availability.

  Example
      {:ok, result} = conn |> ExNylas.Calendars.availability(`body`)
  """
  def availability(%Conn{} = conn, body) do
    API.post(
      "#{conn.api_server}/calendars/availability",
      body,
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response(Availability)
  end

  @doc """
  Get calendar availability.

  Example
      result = conn |> ExNylas.Calendars.availability!(`body`)
  """
  def availability!(%Conn{} = conn, body) do
    case availability(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
