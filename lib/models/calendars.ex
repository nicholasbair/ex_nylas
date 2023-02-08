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
    field(:read_only?, boolean())
  end

  defmodule Build do
    @moduledoc """
    A struct representing a calendar.
    """
    use TypedStruct

    @derive Jason.Encoder
    typedstruct do
      @typedoc "A calendar"
      field(:name, String.t(), enforce: true)
      field(:description, String.t())
      field(:location, String.t())
      field(:timezone, String.t())
    end
  end
end

defmodule ExNylas.Calendar.Availability do
  @moduledoc """
  A struct representing availability.
  """
  use TypedStruct

  typedstruct do
    @typedoc "Calendar availability"
    field(:object, String.t())
    field(:timeslots, list())
  end
end

defmodule ExNylas.Calendar.FreeBusy do
  @moduledoc """
  A struct representing a free busy.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A calendar free busy"
    field(:object, String.t())
    field(:email, String.t())
    field(:timeslots, list())
  end
end

defmodule ExNylas.Calendars do
  @moduledoc """
  Interface for Nylas calendars.
  """

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF
  alias ExNylas.Calendar.Availability
  alias ExNylas.Calendar.FreeBusy

  use ExNylas,
    object: "calendars",
    struct: ExNylas.Calendar,
    include: [:list, :first, :find, :delete, :build, :create, :update]

  @doc """
  Get calendar availability.

  Example
      {:ok, result} = conn |> ExNylas.Calendars.availability(`body`)
  """
  def availability(%Conn{} = conn, body) do
    res =
      API.post(
        "#{conn.api_server}/calendars/availability",
        body,
        API.header_bearer(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, Availability)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
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

  @doc """
  Get calendar free/busy.

  Example
      {:ok, result} = conn |> ExNylas.Calendars.free_busy(`body`)
  """
  def free_busy(%Conn{} = conn, body) do
    res =
      API.post(
        "#{conn.api_server}/calendars/free-busy",
        body,
        API.header_bearer(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, FreeBusy)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Get calendar free/busy.

  Example
      result = conn |> ExNylas.Calendars.free_busy!(`body`)
  """
  def free_busy!(%Conn{} = conn, body) do
    case free_busy(conn, body) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
