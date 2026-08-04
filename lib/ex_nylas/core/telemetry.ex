defmodule ExNylas.Telemetry do
  @moduledoc false

  alias ExNylas.Connection

  @spec maybe_attach_telemetry(Req.Request.t(), Connection.t()) :: Req.Request.t()
  def maybe_attach_telemetry(req, %{telemetry: true} = _conn) do
    ReqTele.attach_default_logger()
    ReqTele.attach(req)
  end

  def maybe_attach_telemetry(req, %{telemetry: false} = _conn), do: req
  def maybe_attach_telemetry(req, _), do: req
end
