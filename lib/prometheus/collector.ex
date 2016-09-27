defmodule Prometheus.Collector do
  @moduledoc """
  A collector for a set of metrics.

  Normal users should use `Prometheus.Metric.Gauge`, `Prometheus.Metric.Counter`, `Prometheus.Metric.Summary`
  and `Prometheus.Metric.Histogram`.

  Implementing `:prometheus_collector` behaviour is for advanced uses such as proxying metrics from another monitoring system.
  It is it the responsibility of the implementer to ensure produced metrics are valid.

  You will be working with Prometheus data model directly (see `Prometheus.Model` ).

  Callbacks:
  - `collect_mf(registry, callback)` - called by exporters and formats.
  Should call `callback` for each `MetricFamily` of this collector;
  - `collect_metrics(name, data)` - called by `MetricFamily` constructor.
  Should return Metric list for each MetricFamily identified by `name`.
  `data` is a term associated with MetricFamily by collect_mf.
  - `deregister_cleanup(registry)` - called when collector unregistered by
  `registry`. If collector is stateful you can put cleanup code here.

  Example (simplified `:prometheus_vm_memory_collector`):

  ```
  defmodule Prometheus.VMMemoryCollector do
    use Prometheus.Collector

    def collect_mf(_registry, callback) do
      memory = :erlang.memory()
      callback.(create_gauge(
            :erlang_vm_bytes_total,
            '''
            The total amount of memory currently allocated.
            This is the same as the sum of the memory size
            for processes and system."
            ''',
            memory))
      :ok
    end

    def collect_metrics(:erlang_vm_bytes_total, memory) do
      Prometheus.Model.gauge_metrics(
        [
          {[kind: :system], memory.system},
          {[kind: :processes], memory.processes}
        ])
    end

    defp create_gauge(name, help, data) do
      Prometheus.Model.create_mf(name, help, :gauge, __MODULE__, data)
    end
  end
  ```
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
