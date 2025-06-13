defmodule ExNylas.Threads do
  @moduledoc """
  Interface for Nylas threads.

  [Nylas docs](https://developer.nylas.com/docs/api/v3/ecc/#tag/threads)
  """

  use ExNylas,
    object: "threads",
    struct: ExNylas.Thread,
    readable_name: "thread",
    include: [:list, :first, :find, :update, :all, :delete]
end
