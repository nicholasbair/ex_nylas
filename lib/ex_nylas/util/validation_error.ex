defmodule ExNylas.ValidationError do
  @moduledoc """
  Exception raised when pre-request validation fails.

  This exception is raised before making an API request when required parameters
  are missing, invalid, or when validation rules are violated.

  ## Fields

    * `message` - Human-readable error message
    * `field` - Field name that failed validation (optional)
    * `details` - Additional context (optional)

  ## Example

      try do
        ExNylas.Core.Auth.auth_bearer(%Connection{api_key: nil})
      rescue
        e in ExNylas.ValidationError ->
          IO.inspect(e.field)   # :access_token
          IO.inspect(e.message) # "Validation failed for access_token: ..."
      end
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
end
