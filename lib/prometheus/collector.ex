defmodule Prometheus.Collector do
  @moduledoc """
  A collector for a set of metrics.

  Normal users should use `Prometheus.Metric.Gauge`, `Prometheus.Metric.Counter`, `Prometheus.Metric.Summary`
  and `Prometheus.Metric.Histogram`.

  Implementing `:prometheus_collector` behaviour is for advanced uses, such as proxying metrics from another monitoring system.
  It is it the responsibility of the implementer to ensure produced metrics are valid.

  You will be working with Prometheus data model directly (see `Prometheus.Model` ).
  """

  require Prometheus.Error

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

  @doc """
  Equivalent to `Prometheus.Registry.register_collector/2`.
  """
  defmacro register(collector, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.register_collector(unquote(registry), unquote(collector))
      )
    end
  end

  @doc """
  Equivalent to `Prometheus.Registry.deregister_collector/2`.
  """
  defmacro deregister(collector, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.deregister_collector(unquote(registry), unquote(collector))
      )
    end
  end

  @doc """
  Calls `callback` for each MetricFamily of this collector.
  """
  defmacro collect_mf(collector, callback, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_collector.collect_mf(unquote(collector), unquote(callback), unquote(registry))
      )
    end
  end

end
