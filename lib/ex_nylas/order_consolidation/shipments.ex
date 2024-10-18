defmodule ExNylas.OrderConsolidation.Shipments do
  @moduledoc """
  Interface for Nylas order consolidation orders.
  """

  use ExNylas,
    object: "consolidated-shipment",
    struct: ExNylas.OrderConsolidation.Shipment,
    readable_name: "extracted shipment",
    include: [:list]
end
