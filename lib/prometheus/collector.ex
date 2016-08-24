defmodule Prometheus.Collector do

  defmacro register(collector, registry \\ :default) do
    quote do
      :prometheus_registry.register_collector(unquote(collector), unquote(registry))
    end
  end

  defmacro deregister(collector, registry \\ :default) do
    quote do
      :prometheus_registry.deregister_collector(unquote(collector), unquote(registry))
    end
  end

  defmacro collecto_mf(collector, callback, registry \\ :default) do
    quote do
      :prometheus_collector.collect_mf(unquote(collector), unquote(callback), unquote(registry))
    end
  end
  
end
