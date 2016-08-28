defmodule Prometheus.Registry do
  @moduledoc """
  A registry of Collectors.

  The majority of users should use the `:default`, rather than their own.

  Creating a registry other than the default is primarily useful for
  unit tests, or pushing a subset of metrics to the
  [Pushgateway](https://github.com/prometheus/pushgateway) from batch jobs.
  """
  require Prometheus.Error

  @doc """
  Calls `callback` for each collector with two arguments: `registry` and `collector`.
  """
  defmacro collect(callback, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.collect(unquote(registry), unquote(callback))
      )
    end
  end

  @doc """
  Returns collectors registered in `registry`.
  """
  defmacro collectors(registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.collectors(unquote(registry))
      )
    end
  end

  @doc """
  Register a collector.
  """
  defmacro register_collector(collector, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.register_collector(unquote(registry), unquote(collector))
      )
    end
  end

  @doc """
  Register collectors list.
  """
  defmacro register_collectors(collectors, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error do
        :prometheus_registry.register_collectors(unquote(registry), unquote(collectors))
      end
    end
  end

  @doc """
  Unregister a collector.
  """
  defmacro deregister_collector(collector, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.deregister_collector(unquote(registry), unquote(collector))
      )
    end
  end

  @doc """
  Unregister all collectors.
  """
  defmacro clear(registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.clear(unquote(registry))
      )
    end
  end

  @doc """
  Check whether `collector` is registered.
  """
  defmacro collector_registred?(collector, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.collector_registeredp(unquote(registry), unquote(collector))
      )
    end
  end

end
