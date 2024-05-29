defmodule ExNylas.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_nylas,
      version: "0.4.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: "Unofficial Elixir SDK for the Nylas API",
      package: package(),
      deps: deps(),
      name: "ExNylas",
      dialyzer: [plt_add_apps: [:mix]],
      aliases: aliases(),
      source_url: url(),
      homepage_url: url(),
      docs: [
        main: "ExNylas",
        extras: ["README.md", "LICENSE"]
      ]
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
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:multipart, "~> 0.4.0"},
      {:polymorphic_embed, "~> 3.0"},
      {:req, "~> 0.4.14"},
      {:req_telemetry, "~> 0.0.4"},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false}
    ]
  end

  defp package do
    [
      name: "ex_nylas",
      licenses: ["MIT"],
      links: %{
        "GitHub" => url(),
      }
    ]
  end

  defp url, do: "https://github.com/nicholasbair/ex_nylas"
end
