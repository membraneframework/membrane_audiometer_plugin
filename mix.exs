defmodule Membrane.Element.Audiometer.Mixfile do
  use Mix.Project

  @version "0.2.0"
  @github_url "https://github.com/membraneframework/membrane-element-audiometer"

  def project do
    [
      app: :membrane_element_audiometer,
      compilers: Mix.compilers(),
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "Membrane Multimedia Framework (Audiometer Element)",
      package: package(),
      name: "Membrane Element: Audiometer",
      source_url: @github_url,
      docs: docs(),
      homepage_url: "https://membraneframework.org",
      preferred_cli_env: [format: :test],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [],
      mod: {Membrane.Element.Audiometer, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      files: ["lib", "mix.exs", "README*", "LICENSE*", ".formatter.exs", "c_src"]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:membrane_core, "~> 0.2"},
      {:membrane_caps_audio_raw, "~> 0.1.2"}
    ]
  end
end
