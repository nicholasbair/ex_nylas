defmodule ExNylas.Neural do
  @moduledoc false
  alias ExNylas.API
  alias ExNylas.Connection, as: Conn

  @doc false
  def feedback(%Conn{} = conn, message_id, component) do
    API.post(
      "#{conn.api_server}/neural/#{component}}",
      %{message_id: message_id},
      API.header_bearer(conn) ++ ["content-type": "application/json"]
    )
    |> API.handle_response()
  end

  defmodule Conversation do
    @moduledoc """
    Interface for Nylas clean conversation API.
    """

    use ExNylas,
      struct: __MODULE__,
      include: [:build]

    alias ExNylas.Connection, as: Conn
    alias ExNylas.API

    defstruct [
      :account_id,
      :bcc,
      :body,
      :cc,
      :date,
      :events,
      :files,
      :folder,
      :from,
      :id,
      :labels,
      :object,
      :reply_to,
      :snippet,
      :starred,
      :subject,
      :thread_id,
      :to,
      :unread,
      :reply_to_message_id,
      :metadata,
      :cids,
      :model_version,
      :conversation,
    ]

    @typedoc "A clean conversation message"
    @type t :: %__MODULE__{
      account_id: String.t(),
      bcc: [ExNylas.Common.EmailParticipant.t()],
      body: String.t(),
      cc: [ExNylas.Common.EmailParticipant.t()],
      date: non_neg_integer(),
      events: [ExNylas.Event.t()],
      files: [ExNylas.File.t()],
      folder: ExNylas.Folder.t(),
      from: [ExNylas.Common.EmailParticipant.t()],
      id: String.t(),
      labels: [ExNylas.Label.t()],
      object: String.t(),
      reply_to: [ExNylas.Common.EmailParticipant.t()],
      snippet: String.t(),
      starred: boolean(),
      subject: String.t(),
      thread_id: String.t(),
      to: [ExNylas.Common.EmailParticipant.t()],
      unread: boolean(),
      reply_to_message_id: String.t(),
      metadata: map(),
      cids: [String.t()],
      model_version: String.t(),
      conversation: String.t(),
    }

    defmodule Build do
      # @derive Jason.Encoder
      # use Domo, skip_defaults: true

      @enforce_keys [:message_id]
      defstruct [
        :message_id,
        :ignore_links,
        :ignore_images,
        :ignore_tables,
        :remove_conclusion_phrases,
        :images_as_markdown,
      ]

      @typedoc "A struct representing the clean conversation request payload."
      @type t :: %__MODULE__{
        message_id: list(),
        ignore_links: boolean(),
        ignore_images: boolean(),
        ignore_tables: boolean(),
        remove_conclusion_phrases: boolean(),
        images_as_markdown: boolean(),
      }
    end

    def as_struct() do
      %ExNylas.Neural.Conversation{
        bcc: [ExNylas.Common.EmailParticipant.as_struct()],
        cc: [ExNylas.Common.EmailParticipant.as_struct()],
        events: [ExNylas.Event.as_struct()],
        files: [ExNylas.File.as_struct()],
        folder: ExNylas.Folder.as_struct(),
        from: [ExNylas.Common.EmailParticipant.as_struct()],
        labels: [ExNylas.Label.as_struct()],
        reply_to: [ExNylas.Common.EmailParticipant.as_struct()],
        to: [ExNylas.Common.EmailParticipant.as_struct()],
      }
    end

    @doc """
    Get the clean conversation for a given message or messages.

    Example
        {:ok, clean} = ExNylas.Neural.CleanConversation.clean(conn, `payload`)
    """
    def clean(%Conn{} = conn, payload) do
      API.put(
        "#{conn.api_server}/neural/conversation",
        payload,
        API.header_bearer(conn) ++ ["content-type": "application/json"]
      )
      |> API.handle_response(as_struct())
    end

    @doc """
    Get the clean conversation for a given message or messages.

    Example
        clean = ExNylas.Neural.Conversation.clean!(conn, `payload`)
    """
    def clean!(%Conn{} = conn, payload) do
      case feedback(conn, payload) do
        {:ok, body} -> body
        {:error, reason} -> raise ExNylasError, reason
      end
    end

    @doc """
    Send feedback for the clean conversation API.

    Example
        {:ok, res} = ExNylas.Neural.Conversation.feedback(conn, `message_id`)
    """
    def feedback(%Conn{} = conn, message_id), do: ExNylas.Neural.feedback(conn, message_id, "conversation")

    @doc """
    Send feedback for the clean conversation API.

    Example
        res = ExNylas.Neural.Conversation.feedback!(conn, `message_id`)
    """
    def feedback!(%Conn{} = conn, message_id) do
      case feedback(conn, message_id) do
        {:ok, body} -> body
        {:error, reason} -> raise ExNylasError, reason
      end
    end
  end

  defmodule Signature do
    @moduledoc """
    Interface for Nylas signature extraction API.
    """

    use ExNylas,
      struct: __MODULE__,
      include: [:build]

    alias ExNylas.Connection, as: Conn
    alias ExNylas.API

    # @derive Nestru.Decoder
    # use Domo, skip_defaults: true

    defstruct [
      :account_id,
      :bcc,
      :body,
      :cc,
      :date,
      :events,
      :files,
      :folder,
      :from,
      :id,
      :labels,
      :object,
      :reply_to,
      :snippet,
      :starred,
      :subject,
      :thread_id,
      :to,
      :unread,
      :reply_to_message_id,
      :metadata,
      :cids,
      :model_version,
      :signature,
      :contacts
    ]

    @typedoc "A signature extraction message"
    @type t :: %__MODULE__{
      account_id: String.t(),
      bcc: [ExNylas.Common.EmailParticipant.t()],
      body: String.t(),
      cc: [ExNylas.Common.EmailParticipant.t()],
      date: non_neg_integer(),
      events: [ExNylas.Event.t()],
      files: [ExNylas.File.t()],
      folder: ExNylas.Folder.t(),
      from: [ExNylas.Common.EmailParticipant.t()],
      id: String.t(),
      labels: [ExNylas.Label.t()],
      object: String.t(),
      reply_to: [ExNylas.Common.EmailParticipant.t()],
      snippet: String.t(),
      starred: boolean(),
      subject: String.t(),
      thread_id: String.t(),
      to: [ExNylas.Common.EmailParticipant.t()],
      unread: boolean(),
      reply_to_message_id: String.t(),
      metadata: map(),
      cids: [String.t()],
      model_version: String.t(),
      signature: String.t(),
      contacts: ExNylas.Neural.Signature.Contacts.t(),
    }

    defmodule Contacts do
      defstruct [
        :job_titles,
        :links,
        :phone_numbers,
        :emails,
        :names,
      ]

      @type t :: %__MODULE__{
        job_titles: [String.t()],
        links: [String.t()],
        phone_numbers: [String.t()],
        emails: [String.t()],
        names: [ExNylas.Neural.Signature.ContactName.t()],
      }

      def as_struct() do
        %ExNylas.Neural.Signature.Contacts{
          names: [ExNylas.Neural.Signature.ContactName.as_struct()]
        }
      end
    end

    defmodule ContactName do
      defstruct [
        :first_name,
        :last_name,
      ]

      @type t :: %__MODULE__{
        first_name: String.t(),
        last_name: String.t(),
      }

      def as_struct() do
        %ExNylas.Neural.Signature.ContactName{}
      end
    end

    def as_struct() do
      %ExNylas.Neural.Signature{
        bcc: [ExNylas.Common.EmailParticipant.as_struct()],
        cc: [ExNylas.Common.EmailParticipant.as_struct()],
        events: [ExNylas.Event.as_struct()],
        files: [ExNylas.File.as_struct()],
        folder: ExNylas.Folder.as_struct(),
        from: [ExNylas.Common.EmailParticipant.as_struct()],
        labels: [ExNylas.Label.as_struct()],
        reply_to: [ExNylas.Common.EmailParticipant.as_struct()],
        to: [ExNylas.Common.EmailParticipant.as_struct()],
        contacts: ExNylas.Neural.Signature.Contacts.as_struct(),
      }
    end

    defmodule Build do
      # @derive Nestru.Decoder
      # use Domo, skip_defaults: true

      @enforce_keys [:message_id]
      defstruct [
        :message_id,
        :ignore_links,
        :ignore_images,
        :ignore_tables,
        :remove_conclusion_phrases,
        :images_as_markdown,
        :parse_contacts,
      ]

      @typedoc "A struct representing the signature extraction request payload."
      @type t :: %__MODULE__{
        message_id: list(),
        ignore_links: boolean(),
        ignore_images: boolean(),
        ignore_tables: boolean(),
        remove_conclusion_phrases: boolean(),
        images_as_markdown: boolean(),
        parse_contacts: boolean(),
      }
    end

    @doc """
    Extract the signature(s) from the provided message IDs.

    Example
        {:ok, signatures} = ExNylas.Neural.Signature.extract(conn, `payload`)
    """
    def extract(%Conn{} = conn, payload) do
      API.put(
        "#{conn.api_server}/neural/signature",
        payload,
        API.header_bearer(conn) ++ ["content-type": "application/json"]
      )
      |> API.handle_response(__MODULE__)
    end

    @doc """
    Extract the signature(s) from the provided message IDs.

    Example
        signatures = ExNylas.Neural.Signature.extract!(conn, `payload`)
    """
    def extract!(%Conn{} = conn, payload) do
      case extract(conn, payload) do
        {:ok, body} -> body
        {:error, reason} -> raise ExNylasError, reason
      end
    end

    @doc """
    Send feedback for the signature API.

    Example
        {:ok, res} = ExNylas.Neural.Signature.feedback(conn, `message_id`)
    """
    def feedback(%Conn{} = conn, message_id), do: ExNylas.Neural.feedback(conn, message_id, "signature")

    @doc """
    Send feedback for the signature API.

    Example
        res = ExNylas.Neural.Signature.feedback!(conn, `message_id`)
    """
    def feedback!(%Conn{} = conn, message_id) do
      case feedback(conn, message_id) do
        {:ok, body} -> body
        {:error, reason} -> raise ExNylasError, reason
      end
    end

  end
end
