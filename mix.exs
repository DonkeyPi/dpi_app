defmodule Ash.App.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_app,
      version: "0.1.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Ash.App.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end
