defmodule ExNylas.ValidationError do
  @moduledoc """
  Exception raised when pre-request validation fails.

  This exception is raised before making an API request when required parameters
  are missing, invalid, or when validation rules are violated.
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
  def exception(%__MODULE__{message: message} = error) when not is_nil(message) do
    error
  end

  @impl true
  def exception(%__MODULE__{message: nil, field: field, details: details} = error)
      when not is_nil(field) and not is_nil(details) do
    %{error | message: "Validation failed for #{field}: #{details}"}
  end

  @impl true
  def exception(%__MODULE__{message: nil, field: field, details: nil} = error)
      when not is_nil(field) do
    %{error | message: "Validation failed for #{field}"}
  end

  @impl true
  def exception(%__MODULE__{message: nil, field: nil, details: details} = error)
      when not is_nil(details) do
    %{error | message: details}
  end

  @impl true
  def exception(%__MODULE__{message: nil, field: nil, details: nil} = error) do
    %{error | message: "Validation failed"}
  end

  @impl true
  def exception(value) when is_map(value) do
    field = get_field(value, :field)
    details = get_field(value, :details)
    message = get_field(value, :message)

    exception(%__MODULE__{
      message: message,
      field: field,
      details: details
    })
  end

  defp get_field(map, key) when is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  @impl true
  def message(%__MODULE__{message: message}) do
    message || "Validation failed"
  end
end
