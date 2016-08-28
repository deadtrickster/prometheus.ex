defmodule Prometheus.Collector do

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

  defmacro collect_mf(collector, callback, registry \\ :default) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_collector.collect_mf(unquote(collector), unquote(callback), unquote(registry))
      )
    end
  end

end

defmodule MyCollector do
  use Prometheus.Collector
end
