defmodule ExNylas.API do
  @moduledoc """
  Utility functions for headers, encoding requests, and decoding responses
  """

  alias ExNylas.Connection, as: Conn
  alias ExNylas.Model.Common.Response
  alias ExNylas.Transform, as: TF

  # Requests ###################################################################

  @base_headers [
    accept: "application/json",
    "user-agent": "ExNylas/" <> Mix.Project.config()[:version]
  ]

  @success_codes Enum.to_list(200..299)

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

  def auth_basic(%Conn{client_id: client_id, client_secret: _client_secret}) when is_nil(client_id) do
    raise ExNylasError, "client_id must be present to use basic auth"
  end

  def auth_basic(%Conn{client_id: _client_id, client_secret: client_secret}) when is_nil(client_secret) do
    raise ExNylasError, "client_secret must be present to use basic auth"
  end

  def auth_basic(%Conn{client_id: client_id, client_secret: client_secret}) do
    {:basic, "#{client_id}:#{client_secret}"}
  end

  def base_headers(opts \\ []), do: Keyword.merge(@base_headers, opts)

  def process_request_body(body) when is_struct(body) do
    body
    |> Map.from_struct()
    |> Poison.encode!()
  end

  def process_request_body(body) when is_map(body), do: Poison.encode!(body)

  def process_request_body(body), do: body

  # Multipart - used by drafts, messages
  def build_multipart(obj, attachments) do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field(Poison.encode!(obj), :message))
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

  def handle_response(res, transform_to \\ nil, use_common_response \\ true) do
    case format_response(res) do
      {:ok, body, true} ->
        TF.transform(body, to_struct(transform_to, use_common_response), true)

      {:ok, body, false} ->
        {:ok, body}

      {:error, body, true} ->
        # transform returns ok tuple if transforming to struct succeeds, even if its an error struct
        {_, val} = TF.transform(body, to_struct(transform_to, use_common_response), true)
        {:error, val}

      {:error, body, false} ->
        {:error, body}

      val -> val
    end
  end

  defp to_struct(transform_to, true = _use_common_response), do: Response.as_struct(transform_to)
  defp to_struct(transform_to, false = _use_common_response), do: transform_to

  defp format_response({:ok, %{status: status, body: body} = res}) when status in @success_codes do
    {:ok, body, should_decode?(res)}
  end

  defp format_response({:ok, %{body: body} = res}) do
    {:error, body, should_decode?(res)}
  end

  defp format_response({:error, %{reason: reason}}) do
    {:error, reason, false}
  end

  defp format_response(res), do: res

  defp should_decode?(%{headers: %{"content-type" => ["application/json" | _]}}), do: true
  defp should_decode?(%{headers: %{"content-type" => ["application/json; charset=utf-8" | _]}}), do: true
  defp should_decode?(_), do: false

  # Handle streaming response for Smart Compose endpoints
  def handle_stream(fun) do
    fn {:data, data}, {req, resp} ->
      transfrom_stream({:data, data}, {req, resp}, fun)
    end
  end

  defp transfrom_stream({:data, data}, {req, %{status: status} = resp}, fun) when status in 200..299 do
    data
    |> String.split("data: ")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(&Poison.decode!(&1))
    |> Enum.reduce("", fn x, acc -> acc <> Map.get(x, "suggestion") end)
    |> fun.()

    {:cont, {req, resp}}
  end

  defp transfrom_stream({:data, data}, {req, resp}, _fun) do
    resp = Map.put(resp, :body, data)
    {:cont, {req, resp}}
  end
end
