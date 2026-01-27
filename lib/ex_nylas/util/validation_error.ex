defmodule ExNylas.ValidationError do
  @moduledoc """
  Exception raised when pre-request validation fails.

  This exception is raised before making an API request when required parameters
  are missing, invalid, or when validation rules are violated.

  ## Fields

    * `message` - Human-readable error message
    * `field` - Field name that failed validation (optional)
    * `details` - Additional context (optional)
  """

  @type t :: %__MODULE__{
          message: String.t(),
          field: atom() | String.t() | nil,
          details: String.t() | nil
        }

  defexception [:message, :field, :details]

  @impl true
  def exception({field, message}) when is_atom(field) or is_binary(field) do
    msg = "Validation failed for #{field}: #{message}"

    %ExNylas.ValidationError{
      message: msg,
      field: field,
      details: message
    }
  end

  @impl true
  def exception(message) when is_binary(message) do
    %ExNylas.ValidationError{
      message: message,
      field: nil,
      details: nil
    }
  end

  @impl true
  def exception(keywords) when is_list(keywords) do
    keywords
    |> Enum.into(%{})
    |> exception()
  end

  @impl true
  def exception(%__MODULE__{} = error) do
    if error.message do
      error
    else
      msg = if error.field do
        "Validation failed for #{error.field}#{if error.details, do: ": #{error.details}", else: ""}"
      else
        error.details || "Validation failed"
      end
      %{error | message: msg}
    end
  end

  @impl true
  def exception(value) when is_map(value) do
    field = Map.get(value, :field) || Map.get(value, "field")
    details = Map.get(value, :details) || Map.get(value, "details")
    message = Map.get(value, :message) || Map.get(value, "message")

    msg = message || if field do
      "Validation failed for #{field}#{if details, do: ": #{details}", else: ""}"
    else
      details || "Validation failed"
    end

    %ExNylas.ValidationError{
      message: msg,
      field: field,
      details: details
    }
  end

  @impl true
  def message(%__MODULE__{message: message}) do
    message || "Validation failed"
  end
end
