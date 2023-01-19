defmodule Dpi.App.MixProject do
  use Mix.Project

  def project do
    [
      app: :dpi_app,
      version: "0.1.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Dpi.App.Application, []},
      extra_applications: [:logger, :public_key, :crypto]
    ]
  end

  defp deps do
    [
      {:zoneinfo, "~> 0.1.5"},
      {:dpi_tool, path: "../dpi_tool"}
    ]
  end
end
