defmodule ExNylas.Webhook do
  @moduledoc """
  A struct representing a webhook.
  """

  defstruct [
    :application_id,
    :callback_url,
    :id,
    :state,
    :triggers,
    :version,
  ]

  @type t :: %__MODULE__{
    application_id: String.t(),
    callback_url: String.t(),
    state: String.t(),
    triggers: [String.t()],
    version: String.t(),
  }

  def as_struct(), do: %ExNylas.Webhook{}

  def as_list, do: [as_struct()]

  defmodule Build do
    defstruct [
      :state,
      :callback_url,
      :triggers,
    ]

    @type t :: %__MODULE__{
      state: String.t(),
      callback_url: String.t(),
      triggers: [String.t()],
    }
  end
end

defmodule ExNylas.Webhooks do
  @moduledoc """
  Interface for Nylas webhook.
  """

  use ExNylas,
    object: "webhooks",
    struct: ExNylas.Webhook,
    header_type: :header_basic,
    use_client_url: true,
    include: [:list, :first, :find, :delete, :build, :update, :create, :all]
end

defmodule ExNylas.WebhookNotification do
  @moduledoc """
  A struct representing a webhook notification.
  """

  alias ExNylas.Connection, as: Conn

  defstruct [
    :deltas
  ]

  @type t :: %__MODULE__{
    deltas: [ExNylas.WebhookNotification.Delta.t()]
  }

  defmodule Delta do
    defstruct [
      :date,
      :object,
      :type,
      :object_data
    ]

    @type t :: %__MODULE__{
      date: non_neg_integer(),
      object: String.t(),
      type: String.t(),
      object_data: ExNylas.WebhookNotification.ObjectData.t(),
    }
  end

  defmodule ObjectData do
    defstruct [
      :namespace_id,
      :account_id,
      :object,
      :attributes,
      :id,
      :metadata,
    ]

    @type t :: %__MODULE__{
      namespace_id: String.t(),
      account_id: String.t(),
      object: String.t(),
      attributes: map(),
      id: String.t(),
      metadata: map(),
    }
  end

 @doc """
  Validate the X-Nylas-Signature header from a webhook.

  Example
      valid = conn |> ExNylas.WebhoookNotification.valid_signature?(body, signature_from_webhook_request)
  """
  def valid_signature?(%Conn{client_secret: secret}, _body, _signature) when is_nil(secret) do
    raise ExNylasError, "ExNylas.Connection struct is missing a value for `client_secret` which is required for this operation."
  end

  def valid_signature?(%Conn{} = _conn, body, _signature) when not is_bitstring(body) do
    raise ExNylasError, "body should be passed as a string."
  end

  def valid_signature?(%Conn{} = conn, body, signature) do
    computed =
      :crypto.mac(:hmac, :sha256, conn.client_secret, body)
      |> Base.encode16
      |> String.downcase()

    computed == String.downcase(signature)
  end
end
