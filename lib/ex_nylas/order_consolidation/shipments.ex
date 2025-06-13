defmodule ExNylas.OrderConsolidation.Shipments do
  @moduledoc """
  Interface for Nylas order consolidation orders.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/extractai)
  """

  use ExNylas,
    object: "consolidated-shipment",
    struct: ExNylas.OrderConsolidation.Shipment,
    readable_name: "extracted shipment",
    include: [:list]
end
