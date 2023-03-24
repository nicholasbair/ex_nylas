defmodule ExNylas.Webhook do
  @moduledoc """
  A struct representing a webhook.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A webhook"
    field(:application_id, String.t())
    field(:callback_url, String.t())
    field(:id, String.t())
    field(:state, String.t())
    field(:triggers, list())
    field(:version, String.t())
  end

  typedstruct module: Build do
    @typedoc "A struct representing the create webhook request payload."
    field(:state, String.t())
    field(:callback_url, String.t(), enforce: true)
    field(:triggers, list(), enforce: true)
  end
end

defmodule ExNylas.Webhooks do
  @moduledoc """
  Interface for Nylas webhook.
  """
  alias ExNylas.Connection, as: Conn

  use ExNylas,
    object: "webhooks",
    struct: ExNylas.Webhook,
    header_type: :header_basic,
    use_client_url: true,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]

  @doc """
  Validate the X-Nylas-Signature header from a webhook.

  Example
      valid = conn |> ExNylas.Webhoooks.valid_signature?(body, signature_from_webhook_request)
  """
  def valid_signature?(%Conn{client_secret: secret}, _body, _signature) when is_nil(secret) do
    raise "ExNylas.Connection struct is missing a value for `client_secret` which is required for this operation."
  end

  def valid_signature?(%Conn{} = _conn, body, _signature) when not is_bitstring(body) do
    raise "body should be passed as a string."
  end

  def valid_signature?(%Conn{} = conn, body, signature) do
    computed =
      :crypto.mac(:hmac, :sha256, conn.client_secret, body)
      |> Base.encode16
      |> String.downcase()

    computed == String.downcase(signature)
  end
end
