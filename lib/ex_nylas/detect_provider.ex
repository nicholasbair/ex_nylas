defmodule ExNylas.DetectProvider do
  @moduledoc """
  A struct representing provider detection for a given email address.
  """
  # @derive Nestru.Decoder
  # use Domo, skip_defaults: true

  defstruct [
    :auth_name,
    :detected,
    :email_address,
    :is_imap,
    :provider_name,
  ]

  @typedoc "Detect provider"
  @type t :: %__MODULE__{
    auth_name: String.t(),
    detected: boolean(),
    email_address: String.t(),
    is_imap: boolean(),
    provider_name: String.t(),
  }

  def as_struct(), do: %ExNylas.DetectProvider{}

  defmodule Build do
    # @derive Jason.Encoder
    # use Domo, skip_defaults: true

    @enforce_keys [:client_id, :client_secret, :email_address]
    defstruct [:client_id, :client_secret, :email_address]

    @typedoc "A struct representing the detect provider request payload"
    @type t :: %__MODULE__{
      client_id: String.t(),
      client_secret: String.t(),
      email_address: String.t(),
    }
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc """
  Detect the provider for a given email address.

  Example
      {:ok, result} = conn |> ExNylas.DetectProvider.detect(`email_address`)
  """
  def detect(%Conn{} = conn, email_address) do
    API.post(
      "#{conn.api_server}/connect/detect-provider",
      %ExNylas.DetectProvider.Build{
        client_id: conn.client_id,
        client_secret: conn.client_secret,
        email_address: email_address
      },
      "content-type": "application/json"
    )
    |> API.handle_response(as_struct())
  end

  @doc """
  Detect the provider for a given email address.

  Example
      result = conn |> ExNylas.DetectProvider.detect!(`email_address`)
  """
  def detect!(%Conn{} = conn, email_address) do
    case detect(conn, email_address) do
      {:ok, res} -> res
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
