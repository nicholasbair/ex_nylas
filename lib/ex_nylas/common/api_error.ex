defmodule ExNylas.APIError do
  @moduledoc """
  Exception raised when the Nylas API returns a non-2xx response.

  This struct represents the error details returned by the Nylas API and can be
  both parsed from API responses (via Ecto changeset) and raised as an exception.

  ## Fields

    * `message` - Human-readable error message from the API
    * `type` - Error type/category from the API
    * `provider_error` - Additional error details from the email provider (if applicable)

  ## Exception Behavior

  This module implements both `TypedEctoSchema` (for parsing API responses) and
  `Exception` (for raising in bang functions).

  [Nylas docs](https://developer.nylas.com/docs/api/v3/errors/)
  """

  use TypedEctoSchema
  import Ecto.Changeset

  @primary_key false

  typed_embedded_schema do
    field(:message, :string)
    field(:provider_error, :map)
    field(:type, :string)
  end

  # Make the struct an exception by adding __exception__ field
  defoverridable __struct__: 0, __struct__: 1

  def __struct__() do
    super() |> Map.put(:__exception__, true)
  end

  def __struct__(kv) do
    super(kv) |> Map.put(:__exception__, true)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    cast(struct, params, __MODULE__.__schema__(:fields))
  end

  # Exception behavior implementation

  def exception(%__MODULE__{} = error) do
    # Already an APIError struct, ensure message is set
    %{error | message: error.message || "API request failed"}
  end

  def exception(message) when is_binary(message) do
    %__MODULE__{message: message}
  end

  def exception(attrs) when is_map(attrs) do
    %__MODULE__{
      message: Map.get(attrs, :message) || Map.get(attrs, "message") || "API request failed",
      type: Map.get(attrs, :type) || Map.get(attrs, "type"),
      provider_error: Map.get(attrs, :provider_error) || Map.get(attrs, "provider_error")
    }
  end

  def message(%__MODULE__{message: message}), do: message || "API request failed"
end
