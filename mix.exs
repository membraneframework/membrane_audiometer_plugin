defmodule Membrane.Audiometer.Plugin.Mixfile do
  use Mix.Project

  @version "0.7.0"
  @github_url "https://github.com/membrane_audiometer_plugin"

  def project do
    [
      app: :membrane_audiometer_plugin,
      compilers: Mix.compilers(),
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "Element capable of measuring audio level",
      package: package(),
      name: "Membrane Audiometer plugin",
      source_url: @github_url,
      docs: docs(),
      homepage_url: "https://membraneframework.org",
      preferred_cli_env: [format: :test],
      deps: deps()
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      },
      files: ["lib", "mix.exs", "README*", "LICENSE*", ".formatter.exs"]
    ]
  end

  defp deps do
    [
      {:membrane_core, "~> 0.9.0"},
      {:membrane_raw_audio_format, "~> 0.8.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
