defmodule ExNylas.OrderConsolidation.Orders do
  @moduledoc """
  Interface for Nylas order consolidation orders.
  """

  use ExNylas,
    object: "consolidated-order",
    struct: ExNylas.OrderConsolidation.Order,
    readable_name: "extracted order",
    include: [:list]
end
