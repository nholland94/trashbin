defmodule Zeus.Mixfile do
  use Mix.Project

  def project do
    [app: :zeus,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {Zeus, []},
     applications: [:logger, :yamerl]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:yamerl, github: "yakaz/yamerl", tag: "v0.3.2-1"},
      {:elli, github: "knutin/elli", tag: "v1.0.5"},
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.2.2"},
      {:poison, "~> 1.5"}
    ]
  end
end
