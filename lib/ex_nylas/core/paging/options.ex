defmodule ExNylas.Paging.Options do
  @moduledoc false

  import ExNylas.Util

  defstruct [
    query: [],
    delay: 0,
    send_to: nil,
    with_metadata: nil
  ]

  @spec from_opts(Keyword.t() | map()) :: t()
  def from_opts(opts) do
    %__MODULE__{
      query: indifferent_get(opts, :query, []),
      delay: indifferent_get(opts, :delay, 0),
      send_to: indifferent_get(opts, :send_to),
      with_metadata: indifferent_get(opts, :with_metadata),
    }
  end

  @type t :: %__MODULE__{
    query: Keyword.t() | map(),
    delay: non_neg_integer(),
    send_to: (any() -> any()) | nil,
    with_metadata: any() | nil
  }
end
