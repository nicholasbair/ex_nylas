defmodule ExNylas.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_nylas,
      version: "0.3.5",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      aliases: aliases(),
    ]
  end

  def cli do
    [
      preferred_envs: [quality_check: :test, qc: :test, t: :test],
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      c: "compile",
      qc: "quality_check",
      t: "test"
    ]
  end

  defp deps do
    [
      {:req, "~> 0.4.8"},
      {:multipart, "~> 0.4.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:bypass, "~> 2.1", only: :test},
      {:ecto, "~> 3.11"},
      {:req_telemetry, "~> 0.0.4"}
    ]
  end
end
