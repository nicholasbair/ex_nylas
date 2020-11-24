defmodule ExNylas.Webhook do
  @moduledoc """
  A struct representing a webhook.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A webhook"
    field :application_id, String.t()
    field :callback_url,   String.t()
    field :id,             String.t()
    field :state,          String.t()
    field :triggers,       list()
    field :version,        String.t()
  end

end

defmodule ExNylas.Webhook.Build do
  @moduledoc """
  A struct representing a webhook.
  """
  use TypedStruct

  # Payload for build webhook
  # callback_url (required)
  # triggers (required)
  # state

  typedstruct do
    @typedoc "A webhook"
    field :state,        String.t()
    field :callback_url, String.t(), enforce: true
    field :triggers,     list(),     enforce: true
  end

end

defmodule ExNylas.Webhooks do
  @moduledoc """
  Interface for Nylas webhook.
  """

  use ExNylas,
    object: "webhooks",
    struct: ExNylas.Webhook,
    except: [:search, :send],
    header_type: :header_basic,
    use_client_url: true

end
