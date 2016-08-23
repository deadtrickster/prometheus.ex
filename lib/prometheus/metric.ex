defmodule Prometheus.Metric do

  defmacro __using__(_opts) do
    quote do
      alias Prometheus.Metric.{Counter,Gauge,Histogram,Summary}
      require Prometheus.Metric.{Counter,Gauge,Histogram,Summary}
    end
  end
  
  def parse_spec(spec) do
    registry = Keyword.get(spec, :registry, :default)
    name = Keyword.fetch!(spec, :name)
    labels = Keyword.get(spec, :labels, [])
    {registry, name, labels}
  end
  
end
