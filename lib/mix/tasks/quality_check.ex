defmodule Mix.Tasks.QualityCheck do
  @moduledoc """
  Runs mix test, mix credo, and mix dialyzer sequentially.
  """

  use Mix.Task

  @shortdoc "Runs mix test, mix credo, and mix dialyzer sequentially."

  def run(_args) do
    Mix.Task.run("test")
    Mix.Task.run("credo")
    Mix.Task.run("dialyzer")
  end
end
