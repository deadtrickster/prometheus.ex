ExUnit.start()

defmodule Prometheus.Case do
  defmacro __using__(_opts) do
    quote do

      use ExUnit.Case

      use Prometheus

      setup do
        collectors = Prometheus.Registry.collectors()
        Prometheus.Registry.clear()
        Prometheus.Registry.clear(:qwe)

        on_exit fn ->
          Prometheus.Registry.clear()
          Prometheus.Registry.clear(:qwe)
          Prometheus.Registry.register_collectors(collectors)
        end
      end

    end
  end
end
