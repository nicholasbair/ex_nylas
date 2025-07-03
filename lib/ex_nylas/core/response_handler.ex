defmodule ExNylas.ResponseHandler do
  @moduledoc false

  alias ExNylas.Transform, as: TF

  @success_codes Enum.to_list(200..299)

  @spec handle_response({atom(), Req.Response.t() | map()}, any(), boolean()) :: {:ok, any()} | {:error, any()}
  def handle_response(res, transform_to \\ nil, use_common_response \\ true) do
    case format_response(res) do
      {:ok, body, status, headers} ->
        {:ok, TF.transform(body, status, headers, transform_to, use_common_response, transform?(res))}

      {:error, body, status, headers} ->
        {:error, TF.transform(body, status, headers, transform_to, use_common_response, transform?(res))}

      {:error, reason} ->
        {:error, reason}

      val -> val
    end
  end

  defp format_response({:ok, %{status: status, body: body, headers: headers}}) when status in @success_codes do
    {:ok, body, status, headers}
  end

  defp format_response({:ok, %{status: status, body: body, headers: headers}}) do
    {:error, body, status, headers}
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
      TF.transform_stream({:data, data}, {req, resp}, fun)
    end
  end
end
