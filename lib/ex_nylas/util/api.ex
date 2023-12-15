defmodule ExNylas.API do
  @moduledoc """
  Utility functions for headers, encoding requests, and decoding responses
  """

  alias ExNylas.Connection, as: Conn
  alias ExNylas.Transform, as: TF

  @base_headers [
    accept: "application/json",
    "user-agent": "ExNylas/" <> Mix.Project.config()[:version]
  ]

  @success_codes Enum.to_list(200..299)

  def auth_bearer(%Conn{grant_id: "me", access_token: access_token}) do
    {:bearer, access_token}
  end

  def auth_bearer(%Conn{api_key: api_key}) do
    {:bearer, api_key}
  end

  def auth_basic(%Conn{client_id: client_id, client_secret: client_secret}) do
    {:basic, "#{client_id}:#{client_secret}"}
  end

  def base_headers(opts \\ []) do
    @base_headers
    |> Keyword.merge(opts)
  end

  def process_request_body({:ok, body}) when is_map(body) or is_struct(body), do: Poison.encode!(body)

  def process_request_body(body) when is_map(body) or is_struct(body), do: Poison.encode!(body)

  def process_request_body(body), do: body

  def handle_response(res, transform_to \\ nil, use_common_response \\ true)
  def handle_response(res, transform_to, _) when is_nil(transform_to) do
    case res do
      {:ok, %Req.Response{status: status, body: body}} ->
        case status do
          status when status in @success_codes ->
            {:ok, body}

          _ ->
            {:error, body}
        end

      {:error, %{reason: reason}} ->
        {:error, reason}

      _ -> res
    end
  end

  def handle_response(res, transform_to, true = _use_common_response) do
    case handle_response(res, nil) do
      {:ok, body} ->
        TF.transform(body, ExNylas.Model.Common.Response.as_struct(transform_to))

      {:error, :timeout} ->
        {:error, :timeout}

      {:error, body} ->
        # transform returns ok tuple if transforming to struct succeeds, even if its an error struct
        {_, val} = TF.transform(body, ExNylas.Model.Common.Response.as_struct(transform_to))
        {:error, val}
    end
  end

  def handle_response(res, transform_to, false = _use_common_response) do
    case handle_response(res, nil) do
      {:ok, body} -> TF.transform(body, transform_to)
      body -> body
    end
  end

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
end
