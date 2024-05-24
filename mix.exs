defmodule ExNylas.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_nylas,
      version: "0.3.9",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: "Unofficial Elixir SDK for the Nylas API",
      package: package(),
      deps: deps(),
      name: "ex_nylas",
      dialyzer: [plt_add_apps: [:mix]],
      aliases: aliases(),
      source_url: "https://github.com/nicholasbair/ex_nylas",
      homepage_url: "https://github.com/nicholasbair/ex_nylas",
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
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.11"},
      {:multipart, "~> 0.4.0"},
      {:polymorphic_embed, "~> 3.0"},
      {:req, "~> 0.4.14"},
      {:req_telemetry, "~> 0.0.4"}
    ]
  end

  defp package do
    [
      name: "ex_nylas",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/nicholasbair/ex_nylas",
      }
    ]
  end
end
