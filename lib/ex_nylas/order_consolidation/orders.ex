defmodule ExNylas.OrderConsolidation.Orders do
  @moduledoc """
  Interface for Nylas order consolidation orders.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/extractai)
  """

  use ExNylas,
    object: "consolidated-order",
    struct: ExNylas.OrderConsolidation.Order,
    readable_name: "extracted order",
    include: [:list]
end
