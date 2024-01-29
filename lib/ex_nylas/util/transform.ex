defmodule ExNylas.Transform do
  @moduledoc """
  Generic transform functions for data returned by the Nylas API
  """

  @status_codes %{
    200 => :ok,
    201 => :created,
    202 => :accepted,
    204 => :no_content,
    400 => :bad_request,
    401 => :unauthorized,
    403 => :forbidden,
    404 => :not_found,
    405 => :method_not_allowed,
    406 => :not_acceptable,
    409 => :conflict,
    410 => :gone,
    413 => :payload_too_large,
    429 => :too_many_requests,
    500 => :internal_server_error,
    503 => :service_unavailable,
    504 => :gateway_timeout
  }

  def transform(object_or_objects, status, struct, true = _decode?) do
    object_or_objects
    |> Poison.decode(%{as: struct})
    |> insert_status(status)
  end

  def transform(object_or_objects, _status, _struct, false = _decode?), do: object_or_objects

  defp insert_status({:ok, %ExNylas.Model.Common.Response{} = response}, status) do
    {:ok, Map.put(response, :status, status_to_atom(status))}
  end

  defp insert_status(response, _status), do: response

  defp status_to_atom(status) do
    Map.get(@status_codes, status, :unknown)
  end
end
