defmodule ExNylas.Telemetry do
  @moduledoc false

  alias ExNylas.Connection, as: Conn

  @spec maybe_attach_telemetry(Req.Request.t(), Conn.t()) :: Req.Request.t()
  def maybe_attach_telemetry(req, %{telemetry: true} = _conn) do
    ReqTelemetry.attach_default_logger()
    ReqTelemetry.attach(req)
  end

  def maybe_attach_telemetry(req, %{telemetry: false} = _conn), do: req
  def maybe_attach_telemetry(req, _), do: req
end
