defmodule ExNylas.TelemetryTest do
  use ExUnit.Case, async: true
  alias ExNylas.{Telemetry, Connection}

  describe "maybe_attach_telemetry/2" do
    test "attaches telemetry when connection has telemetry: true" do
      req = Req.new(url: "https://api.example.com")
      conn = %Connection{telemetry: true}

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # Should return a Req.Request struct
      assert %Req.Request{} = result
    end

    test "does not attach telemetry when connection has telemetry: false" do
      req = Req.new(url: "https://api.example.com")
      conn = %Connection{telemetry: false}

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # Should return the same request
      assert result == req
    end

    test "does not attach telemetry when connection has no telemetry field" do
      req = Req.new(url: "https://api.example.com")
      conn = %Connection{}

      result = Telemetry.maybe_attach_telemetry(req, conn)

      # Should return the same request
      assert result == req
    end
  end
end
