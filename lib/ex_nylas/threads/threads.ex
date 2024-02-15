defmodule ExNylas.Threads do
  @moduledoc """
  Interface for Nylas threads.
  """

  use ExNylas,
    object: "threads",
    struct: ExNylas.Thread,
    readable_name: "thread",
    include: [:list, :first, :find, :update, :all, :delete]
end
