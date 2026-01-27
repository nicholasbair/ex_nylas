defmodule ExNylas.HostedAuthentication.Error do
  @moduledoc """
  Exception raised when hosted authentication code exchange fails.

  This exception preserves OAuth-specific error fields from the Nylas API

  ## Fields

    * `message` - Human-readable error message (auto-generated from `error` field)
    * `error` - OAuth error code (e.g., "invalid_grant")
    * `error_code` - Numeric error code
    * `error_uri` - URI with more information about the error
    * `request_id` - Nylas request ID for debugging

  [Nylas docs](https://developer.nylas.com/docs/api/v3/admin/#tag/authentication-apis)
  """

  defexception [:message, :error, :error_code, :error_uri, :request_id]

  @type t :: %__MODULE__{
          message: String.t(),
          error: String.t() | nil,
          error_code: integer() | nil,
          error_uri: String.t() | nil,
          request_id: String.t() | nil
        }

  @impl true
  def exception(%__MODULE__{} = oauth_error) do
    %{oauth_error | message: build_message(oauth_error.error)}
  end

  @impl true
  def exception(message) when is_binary(message) do
    %__MODULE__{
      message: build_message(message),
      error: message
    }
  end

  @impl true
  def exception(keywords) when is_list(keywords) do
    keywords
    |> Enum.into(%{})
    |> exception()
  end

  @impl true
  def exception(value) when is_map(value) do
    error_field = Map.get(value, :error) || Map.get(value, "error")

    %__MODULE__{
      message: build_message(error_field),
      error: error_field,
      error_code: Map.get(value, :error_code) || Map.get(value, "error_code"),
      error_uri: Map.get(value, :error_uri) || Map.get(value, "error_uri"),
      request_id: Map.get(value, :request_id) || Map.get(value, "request_id")
    }
  end

  @impl true
  def message(%__MODULE__{message: message}) do
    message || "OAuth error: Authentication code exchange failed"
  end

  defp build_message(nil), do: "OAuth error: Authentication code exchange failed"
  defp build_message(error), do: "OAuth error: #{error}"
end
