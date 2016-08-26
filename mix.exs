defmodule PrometheusEx.Mixfile do
  use Mix.Project

  def project do
    [app: :prometheus_ex,
     version: "0.0.2",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps()]
  end

  def application do
    [applications: [:logger,
                    :prometheus]]
  end

  defp description do
    """
    Elixir-friendly Prometheus monitoring system client.
    """
  end

  defp package do
    [maintainers: ["Ilya Khaprov"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/deadtrickster/prometheus.ex",
              "Prometheus.erl" => "https://hex.pm/packages/prometheus",
              "Ecto Instrumenter" => "https://hex.pm/packages/prometheus_ecto",
              "Phoenix Instrumenter" => "https://hex.pm/packages/prometheus_phoenix",
              "Plugs Instrumenter/Exporter" => "https://hex.pm/packages/prometheus_plugs",
              "Process info Collector" => "https://hex.pm/packages/prometheus_process_collector"}]
  end

  defp deps do
    [{:prometheus, "~> 2.2.0"}]
  end
end
