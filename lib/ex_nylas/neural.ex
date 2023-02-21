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
    use TypedStruct
    use ExNylas,
      struct: __MODULE__,
      include: [:build]

    alias ExNylas.Connection, as: Conn
    alias ExNylas.API

    typedstruct do
      @typedoc "A clean conversation message"
      field(:account_id, String.t())
      field(:bcc, list())
      field(:body, String.t())
      field(:cc, list())
      field(:date, non_neg_integer())
      field(:events, list())
      field(:files, list())
      field(:folder, map())
      field(:from, list())
      field(:id, String.t())
      field(:labels, list())
      field(:object, String.t())
      field(:reply_to, list())
      field(:snippet, String.t())
      field(:starred, boolean())
      field(:subject, String.t())
      field(:thread_id, String.t())
      field(:to, list())
      field(:unread, boolean())
      field(:reply_to_message_id, String.t())
      field(:metadata, map())
      field(:cids, list())
      field(:model_version, String.t())
      field(:conversation, String.t())
    end

    typedstruct module: Build do
      @typedoc "A struct representing the clean conversation request payload."
      field(:message_id, list(), enforce: true)
      field(:ignore_links, boolean())
      field(:ignore_images, boolean())
      field(:ignore_tables, boolean())
      field(:remove_conclusion_phrases, boolean())
      field(:images_as_markdown, boolean())
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
      |> API.handle_response(__MODULE__)
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

    use TypedStruct
    use ExNylas,
      struct: __MODULE__,
      include: [:build]

    alias ExNylas.Connection, as: Conn
    alias ExNylas.API

    typedstruct do
      @typedoc "A signature extraction message"
      field(:account_id, String.t())
      field(:bcc, list())
      field(:body, String.t())
      field(:cc, list())
      field(:date, non_neg_integer())
      field(:events, list())
      field(:files, list())
      field(:folder, map())
      field(:from, list())
      field(:id, String.t())
      field(:labels, list())
      field(:object, String.t())
      field(:reply_to, list())
      field(:snippet, String.t())
      field(:starred, boolean())
      field(:subject, String.t())
      field(:thread_id, String.t())
      field(:to, list())
      field(:unread, boolean())
      field(:reply_to_message_id, String.t())
      field(:metadata, map())
      field(:cids, list())
      field(:model_version, String.t())
      field(:signature, String.t())
      field(:contacts, map())
    end

    typedstruct module: Build do
      @typedoc "A struct representing the signature extraction request payload."
      field(:message_id, list(), enforce: true)
      field(:ignore_links, boolean())
      field(:ignore_images, boolean())
      field(:ignore_tables, boolean())
      field(:remove_conclusion_phrases, boolean())
      field(:images_as_markdown, boolean())
      field(:parse_contacts, boolean())
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
