defmodule Prometheus.Metric.Counter do
  alias Prometheus.Metric
  
  defmacro new(spec) do
    {registry, _, _} = Metric.parse_spec(spec)

    quote do
      :prometheus_counter.new(unquote(spec), unquote(registry))
    end
  end

  defmacro declare(spec) do
    {registry, _, _} = Metric.parse_spec(spec)

    quote do
      :prometheus_counter.declare(unquote(spec), unquote(registry))
    end
  end

  defmacro inc(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_counter.inc(unquote(registry), unquote(name), unquote(labels),  unquote(value))
    end
  end

  defmacro dinc(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_counter.dinc(unquote(registry), unquote(name), unquote(labels),  unquote(value))
    end
  end

  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)
    
    quote do
      :prometheus_counter.reset(unquote(registry), unquote(name), unquote(labels))
    end
  end  

  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)
    
    quote do
      :prometheus_counter.value(unquote(registry), unquote(name), unquote(labels))
    end
  end
end
