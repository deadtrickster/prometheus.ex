defmodule Prometheus.Metric do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      alias Prometheus.Metric.{Counter,Gauge,Histogram,Summary,Boolean}
      require Prometheus.Metric.{Counter,Gauge,Histogram,Summary,Boolean}
    end
  end

  defmacro ct_parsable_spec?(spec) do
    quote do
      is_list(unquote(spec)) or is_atom(unquote(spec))
    end
  end

  def parse_spec(spec) when is_list(spec) do
    registry = Keyword.get(spec, :registry, :default)
    name = Keyword.fetch!(spec, :name)
    labels = Keyword.get(spec, :labels, [])
    {registry, name, labels}
  end
  def parse_spec(spec) when is_atom(spec) do
    {:default, spec, []}
  end

end
