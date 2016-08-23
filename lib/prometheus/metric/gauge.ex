defmodule Prometheus.Metric.Gauge do
  alias Prometheus.Metric
  
  defmacro new(spec) do
    {registry, _, _} = Metric.parse_spec(spec)

    quote do
      :prometheus_gauge.new(unquote(spec), unquote(registry))
    end
  end

  defmacro declare(spec) do
    {registry, _, _} = Metric.parse_spec(spec)

    quote do
      :prometheus_gauge.declare(unquote(spec), unquote(registry))
    end
  end

  defmacro set(spec, value) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_gauge.set(unquote(registry), unquote(name), unquote(labels),  unquote(value))
    end
  end

  defmacro set_to_current_time(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_gauge.set_to_current_time(unquote(registry), unquote(name), unquote(labels))
    end
  end  

  defmacro track_inprogress(spec, fun) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_gauge.track_inprogress(unquote(registry), unquote(name), unquote(labels), unquote(fun))
    end
  end

  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)
    
    quote do
      :prometheus_gauge.reset(unquote(registry), unquote(name), unquote(labels))
    end
  end  

  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)
    
    quote do
      :prometheus_gauge.value(unquote(registry), unquote(name), unquote(labels))
    end
  end
end
