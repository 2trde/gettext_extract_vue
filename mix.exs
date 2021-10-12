defmodule GettextExtractVue.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gettext_extract_vue,
      version: "0.1.0",
      build_path: "_build",
      config_path: "config/config.exs",
      deps_path: "deps",
      lockfile: "mix.lock",
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    []
  end

  defp deps do
    [
      {:gettext, "~> 0.16"},
      {:meck, "~> 0.8"},
      {:poison, "~>4.0"}
    ]
  end
end
