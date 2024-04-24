defmodule ExNylas.API do
  @moduledoc """
  Utility functions for headers, encoding requests, and decoding responses
  """

  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  # Requests ###################################################################

  @base_headers [
    accept: "application/json",
    "user-agent": "ExNylas/" <> Mix.Project.config()[:version]
  ]

  @success_codes Enum.to_list(200..299)

  @spec auth_bearer(Conn.t()) :: {:bearer, String.t()}
  def auth_bearer(%Conn{grant_id: "me", access_token: access_token}) when is_nil(access_token) do
    raise ExNylasError, "access_token must be present when using grant_id='me'"
  end

  def auth_bearer(%Conn{grant_id: "me", access_token: access_token}) do
    {:bearer, access_token}
  end

  def auth_bearer(%Conn{api_key: api_key}) when is_nil(api_key) do
    raise ExNylasError, "missing value for api_key"
  end

  def auth_bearer(%Conn{api_key: api_key}) do
    {:bearer, api_key}
  end

  @spec auth_basic(Conn.t()) :: {:basic, String.t()}
  def auth_basic(%Conn{client_id: client_id, client_secret: _client_secret}) when is_nil(client_id) do
    raise ExNylasError, "client_id must be present to use basic auth"
  end

  def auth_basic(%Conn{client_id: _client_id, client_secret: client_secret}) when is_nil(client_secret) do
    raise ExNylasError, "client_secret must be present to use basic auth"
  end

  def auth_basic(%Conn{client_id: client_id, client_secret: client_secret}) do
    {:basic, "#{client_id}:#{client_secret}"}
  end

  @spec base_headers([any()]) :: Keyword.t()
  def base_headers(opts \\ []), do: Keyword.merge(@base_headers, opts)

  # Multipart - used by drafts, messages
  @spec build_multipart(map(), [tuple()]) :: {Enum.t(), String.t(), integer()}
  def build_multipart(obj, attachments) do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field(Jason.encode!(obj), :message))
      |> add_attachments(attachments)

    {
      Multipart.body_stream(multipart),
      Multipart.content_type(multipart, "multipart/form-data"),
      Multipart.content_length(multipart)
    }
  end

  defp add_attachments(multipart, attachments) do
    Enum.reduce(attachments, multipart, fn f, multipart ->
      multipart
      |> Multipart.add_part(build_file(f))
    end)
  end

  defp build_file({cid, file_path}) do
    {filename, file_contents} = get_file_data(file_path)

    Multipart.Part.file_content_field(filename, file_contents, cid, filename: filename)
  end

  defp build_file(file_path) do
    {filename, file_contents} = get_file_data(file_path)

    Multipart.Part.file_content_field(filename, file_contents, :file, filename: filename)
  end

  defp get_file_data(file_path) do
    filename = Path.basename(file_path)
    {:ok, file_contents} = File.read(file_path)

    {filename, file_contents}
  end

  # Responses ###################################################################

  @spec handle_response({atom(), Req.Response.t()}, any(), boolean()) :: {:ok, any()} | {:error, any()}
  def handle_response(res, transform_to \\ nil, use_common_response \\ true) do
    case format_response(res) do
      {:ok, body, status} ->
        {:ok, TF.transform(body, status, transform_to, use_common_response, transform?(res))}

      {:error, body, status} ->
        {:error, TF.transform(body, status, transform_to, use_common_response, transform?(res))}

      {:error, reason} ->
        {:error, reason}

      val -> val
    end
  end

  defp format_response({:ok, %{status: status, body: body}}) when status in @success_codes do
    {:ok, body, status}
  end

  defp format_response({:ok, %{status: status, body: body}}) do
    {:error, body, status}
  end

  defp format_response({:error, %{reason: reason}}) do
    {:error, reason}
  end

  defp format_response(res), do: res

  defp transform?({_, %{headers: %{"content-type" => content_type}}}) do
    Enum.any?(content_type, &String.contains?(&1, "application/json"))
  end

  defp transform?(_), do: false

  # Handle streaming response for Smart Compose endpoints
  @spec handle_stream(function()) :: function()
  def handle_stream(fun) do
    fn {:data, data}, {req, resp} ->
      TF.transfrom_stream({:data, data}, {req, resp}, fun)
    end
  end

  # Telemetry ##############################################################
  @spec maybe_attach_telemetry(Req.Request.t(), Conn.t()) :: Req.Request.t()
  def maybe_attach_telemetry(req, %{telemetry: true} = _conn) do
    ReqTelemetry.attach_default_logger()
    ReqTelemetry.attach(req)
  end
  def maybe_attach_telemetry(req, %{telemetry: false} = _conn), do: req
  def maybe_attach_telemetry(req, _), do: req
end
