defmodule ExNylas.API do
  @moduledoc false

  @base_headers [
    accept: "application/json",
    "user-agent": "ExNylas/" <> Mix.Project.config()[:version]
  ]

  @spec base_headers([{atom(), String.t()}]) :: Keyword.t()
  def base_headers(opts \\ []), do: Keyword.merge(@base_headers, opts)
end
