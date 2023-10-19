defmodule ExNylas.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_nylas,
      version: "0.2.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.1"},
      {:poison, "~> 5.0"},
      {:bypass, "~> 2.1", only: :test},
      {:typed_struct, "~> 0.3.0"}
    ]
  end
end
