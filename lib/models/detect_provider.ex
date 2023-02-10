defmodule ExNylas.DetectProvider do
  @moduledoc """
  A struct representing provider detection for a given email address.
  """
  use TypedStruct

  typedstruct do
    @typedoc "Detect provider"
    field(:auth_name, String.t())
    field(:detected, boolean())
    field(:email_address, String.t())
    field(:is_imap, boolean())
    field(:provider_name, String.t())
  end

  defmodule Build do
    @moduledoc """
    A struct representing provider detection request payload for a given email address.
    """
    use TypedStruct

    typedstruct enforce: true do
      @typedoc "Detect provider"
      field(:client_id, String.t())
      field(:client_secret, String.t())
      field(:email_address, String.t())
    end
  end

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  @doc """
  Detect the provider for a given email address.

  Example
      {:ok, result} = conn |> ExNylas.DetectProvider.detect(`email_address`)
  """
  def detect(%Conn{} = conn, email_address) do
    res =
      API.post(
        "#{conn.api_server}/connect/detect-provider",
        %ExNylas.DetectProvider.Build{
          client_id: conn.client_id,
          client_secret: conn.client_secret,
          email_address: email_address
        },
        []
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, __MODULE__)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
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
