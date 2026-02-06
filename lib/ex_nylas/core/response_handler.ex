defmodule ExNylas.ResponseHandler do
  @moduledoc false

  alias ExNylas.{
    DecodeError,
    Error,
    Response,
    TransportError
  }
  alias ExNylas.Transform, as: TF

  @success_codes Enum.to_list(200..299)

  @spec handle_response({atom(), Req.Response.t() | map()}, any(), boolean()) ::
    {:ok, any()} | {:error, ExNylas.error_reason()}
  def handle_response(res, transform_to \\ nil, use_common_response \\ true) do
    res
    |> format_response()
    |> handle_formatted_response(res, transform_to, use_common_response)
  end

  defp handle_formatted_response({:ok, body, status, headers}, res, transform_to, use_common_response) do
    body
    |> TF.transform(status, headers, transform_to, use_common_response, transform?(res))
    |> handle_success_transform()
  end

  defp handle_formatted_response({:error, body, status, headers}, res, transform_to, use_common_response) do
    body
    |> TF.transform(status, headers, transform_to, use_common_response, transform?(res))
    |> handle_error_transform()
  end

  defp handle_formatted_response({:error, reason}, _res, _transform_to, _use_common_response)
       when is_atom(reason) do
    {:error, TransportError.exception(reason)}
  end

  defp handle_formatted_response({:error, reason}, _res, _transform_to, _use_common_response) do
    {:error, Error.exception(reason)}
  end

  defp handle_formatted_response(val, _res, _transform_to, _use_common_response) do
    val
  end

  defp handle_success_transform(%DecodeError{} = error), do: {:error, error}
  defp handle_success_transform(result), do: {:ok, result}

  defp handle_error_transform(%Response{} = resp), do: {:error, resp}
  defp handle_error_transform(%DecodeError{} = error), do: {:error, error}
  defp handle_error_transform(%{__struct__: _} = struct), do: {:error, Error.exception(struct)}
  defp handle_error_transform(non_json_response) do
    {:error, DecodeError.exception({:invalid_response_format, non_json_response})}
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
