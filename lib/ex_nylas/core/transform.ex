defmodule ExNylas.Transform do
  @moduledoc false

  alias ExNylas.DecodeError
  alias ExNylas.Response
  import Ecto.Changeset
  import ExNylas, only: [format_module_name: 1]
  require Logger

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
    411 => :length_required,
    412 => :precondition_failed,
    413 => :payload_too_large,
    414 => :uri_too_long,
    415 => :unsupported_media_type,
    418 => :im_a_teapot,
    429 => :too_many_requests,
    500 => :internal_server_error,
    501 => :not_implemented,
    502 => :bad_gateway,
    503 => :service_unavailable,
    504 => :gateway_timeout
  }

  @spec transform(map() | binary(), integer(), map(), atom(), true, true) ::
          Response.t() | DecodeError.t()
  @spec transform(map() | binary(), integer(), map(), atom(), false, true) :: [struct()] | struct()
  @spec transform(map() | binary(), integer(), map(), atom(), boolean(), false) :: any()
  def transform(body, status, headers, model, true = _use_common, true = _transform) do
    case preprocess_body(model, body, status, headers) do
      {:decode_error, reason, raw_body} ->
        DecodeError.exception({reason, raw_body})

      processed_body ->
        %Response{}
        |> Response.changeset(processed_body)
        |> apply_changes()
    end
  end

  def transform(body, _status, _headers, model, false = _use_common, true = _transform) do
    preprocess_data(model, body)
  end

  def transform(body, _status, _headers, _model, _use_common, false = _transform), do: body

  @spec transform_stream({:data, binary()}, {map(), map()}, (-> any())) :: {:cont, {map(), map()}}
  def transform_stream({:data, data}, {req, %{status: status} = resp}, fun) when status in 200..299 do
    json_string =
      ~r/\{.*?\}/
      |> Regex.scan(data)
      |> List.first("{}")

    case Jason.decode(json_string) do
      {:ok, decoded} ->
        decoded
        |> Map.get("suggestion")
        |> fun.()

      {:error, _} ->
        # If decode fails, skip this data chunk
        :ok
    end

    {:cont, {req, resp}}
  end

  def transform_stream({:data, data}, {req, resp}, _fun) do
    resp = Map.put(resp, :body, data)
    {:cont, {req, resp}}
  end

  defp preprocess_body(model, body, status, headers) when is_map(body) do
    data = Map.get(body, "data")

    body
    |> Map.put("data", preprocess_data(model, data))
    |> Map.put("status", status_to_atom(status))
    |> Map.put("headers", headers)
  end

  # SmartCompose stream response can be an event stream if succussful or a JSON object in case of an error.
  defp preprocess_body(model, body, status, headers) when is_bitstring(body) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        preprocess_body(model, decoded, status, headers)

      {:error, reason} ->
        {:decode_error, reason, body}
    end
  end

  defp preprocess_body(_model, body, _status, _headers), do: body

  @spec preprocess_data(nil | atom(), map()) :: [Ecto.Schema.t()] | [map()] | Ecto.Schema.t() | map()
  def preprocess_data(nil, data), do: data

  def preprocess_data(model, data) when is_map(data) do
    model.__struct__()
    |> model.changeset(remove_nil_values(data))
    |> log_validations(model)
    |> apply_changes()
  end

  def preprocess_data(model, data) when is_list(data) do
    Enum.map(data, &preprocess_data(model, &1))
  end

  def preprocess_data(_model, data), do: data

  defp log_validations(%{valid?: true} = changeset, _model), do: changeset

  defp log_validations(changeset, model) do
    traverse_errors(changeset, fn _changeset, field, {msg, opts} ->
      Logger.warning("Validation error while transforming #{format_module_name(model)}: #{field} #{msg} #{inspect(opts)}")
    end)

    changeset
  end

  defp status_to_atom(status), do: Map.get(@status_codes, status, :unknown)

  # Nylas sometimes returns a nil value for a field where a list is expected,
  # which causes an Ecto validation error.
  defp remove_nil_values(data), do: Map.reject(data, fn {_k, v} -> v == nil end)
end
