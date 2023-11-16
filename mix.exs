defmodule PrometheusEx.Mixfile do
  use Mix.Project

  @source_url "https://github.com/deadtrickster/prometheus.ex"
  @version "3.1.0"

  def project do
    [
      app: :prometheus_ex,
      version: @version,
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      name: "Prometheus.ex",
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test],
      docs: [
        main: Prometheus,
        source_ref: "v#{@version}",
        source_url: @source_url,
        extras: [
          "pages/Mnesia Collector.md",
          "pages/VM Memory Collector.md",
          "pages/VM Statistics Collector.md",
          "pages/VM System Info Collector.md",
          "pages/Time.md"
        ]
      ]
    ]
  end

  def application do
    [applications: [:logger, :mnesia, :prometheus]]
  end

  defp description do
    """
    Elixir-friendly Prometheus monitoring system client.
    """
  end

  defp package do
    [
      maintainers: ["Ilya Khaprov"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Prometheus.erl" => "https://hex.pm/packages/prometheus",
        "Inets HTTPD Exporter" => "https://hex.pm/packages/prometheus_httpd",
        "Ecto Instrumenter" => "https://hex.pm/packages/prometheus_ecto",
        "Phoenix Instrumenter" => "https://hex.pm/packages/prometheus_phoenix",
        "Plugs Instrumenter/Exporter" => "https://hex.pm/packages/prometheus_plugs",
        "Process info Collector" => "https://hex.pm/packages/prometheus_process_collector"
      }
    ]
  end

  defp deps do
    [
      {:prometheus, "~> 4.0"},

      ## test
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev]},
      {:earmark, "~> 1.3", only: [:dev]},
      {:ex_doc, "~> 0.19", only: [:dev]},
      {:excoveralls, "~> 0.10", only: [:test]},
    ]
  end
end
