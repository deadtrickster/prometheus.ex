defmodule Prometheus.Collector do

  require Prometheus.Error  
  
  defmacro register(collector, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.register_collector(unquote(collector), unquote(registry))
      )
    end
  end

  defmacro deregister(collector, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_registry.deregister_collector(unquote(collector), unquote(registry))
      )
    end
  end

  defmacro collecto_mf(collector, callback, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_collector.collect_mf(unquote(collector), unquote(callback), unquote(registry))
      )
    end
  end

end
