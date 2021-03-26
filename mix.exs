defmodule Chronicle.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :chronicle,
      version: @version,
      elixir: "~> 1.11",
      description: "An experimental distributed commit log with a Kafkaesque storage layer",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    %{
      maintainers: ["Simon Thörnqvist"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/drowzy/chronicle"
      }
    }
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
