defmodule Prometheus.Collector do
  @moduledoc """
  A collector for a set of metrics.

  Normal users should use `Prometheus.Metric.Gauge`, `Prometheus.Metric.Counter`, `Prometheus.Metric.Summary`
  and `Prometheus.Metric.Histogram`.

  Implementing `:prometheus_collector` behaviour is for advanced uses, such as proxying metrics from another monitoring system.
  It is it the responsibility of the implementer to ensure produced metrics are valid.

  You will be working with Prometheus data model directly (see `Prometheus.Model` ).
  """

  defmacro __using__(_opts) do

    quote location: :keep do
      @behaviour :prometheus_collector

      require Prometheus.Error
      require Prometheus.Model

      def deregister_cleanup(_registry) do
        :ok
      end

      defoverridable [deregister_cleanup: 1]

    end

  end

  use Prometheus.Erlang, :prometheus_collector

  @doc """
  Calls `callback` for each MetricFamily of this collector.
  """
  defmacro collect_mf(registry \\ :default, collector, callback) do
    Erlang.call([registry, collector, callback])
  end

end
