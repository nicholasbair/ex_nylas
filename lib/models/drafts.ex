defmodule ExNylas.Draft do
  @moduledoc """
  A struct representing a draft.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A draft"
    field(:id, String.t())
    field(:object, String.t())
    field(:account_id, String.t())
    field(:subject, String.t())
    field(:from, list())
    field(:reply_to, list())
    field(:to, list())
    field(:cc, list())
    field(:bcc, list())
    field(:date, non_neg_integer())
    field(:thread_id, String.t())
    field(:snippet, String.t())
    field(:body, String.t())
    field(:unread, boolean())
    field(:starred, boolean())
    field(:files, list())
    field(:events, list())
    field(:labels, list())
    field(:version, String.t())
    field(:job_status_id, String.t())
    field(:reply_to_message_id, String.t())
  end

  defmodule Build do
    @moduledoc """
    A struct representing a draft.
    """
    use TypedStruct

    typedstruct do
      @typedoc "A draft"
      field(:subject, String.t())
      field(:to, list())
      field(:cc, list())
      field(:bcc, list())
      field(:from, list())
      field(:reply_to, list())
      field(:reply_to_message_id, String.t())
      field(:file_ids, list())
    end
  end
end

defmodule ExNylas.Drafts do
  @moduledoc """
  Interface for Nylas Drafts.
  """
  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  use ExNylas,
    object: "drafts",
    struct: ExNylas.Draft,
    include: [:list, :first, :find, :delete, :build, :create, :update]

  @doc """
  Send a draft.

  Example
      {:ok, sent_message} = conn |> ExNylas.Drafts.send(`draft_id`, `version`)
  """
  def send(%Conn{} = conn, draft_id, version, tracking \\ %{}) do
    res =
      API.post(
        "#{conn.api_server}/send",
        %{
          draft_id: draft_id,
          version: version,
          tracking: tracking
        },
        API.header_bearer(conn)
      )

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, TF.transform(body, ExNylas.Message)}

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Send a draft.

  Example
      {:ok, sent_message} = conn |> ExNylas.Drafts.send!(`draft_id`, `version`)
  """
  def send!(%Conn{} = conn, draft_id, version, tracking \\ %{}) do
    case send(conn, draft_id, version, tracking) do
      {:ok, body} -> body
      {:error, reason} -> raise ExNylasError, reason
    end
  end
end
