defmodule Prometheus.Metric.Summary do
  alias Prometheus.Metric

  defmacro new(spec) do
    {registry, _, _} = Metric.parse_spec(spec)

    quote do
      :prometheus_summary.new(unquote(spec), unquote(registry))
    end
  end

  defmacro declare(spec) do
    {registry, _, _} = Metric.parse_spec(spec)

    quote do
      :prometheus_summary.declare(unquote(spec), unquote(registry))
    end
  end

  defmacro observe(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_summary.observe(unquote(registry),
        unquote(name), unquote(labels),  unquote(value))
    end
  end

  defmacro dobserve(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_summary.dobserve(unquote(registry),
        unquote(name), unquote(labels), unquote(value))
    end
  end

  defmacro observe_duration(spec, fun) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_summary.observe_duration(unquote(name),
        unquote(registry), unquote(labels), unquote(fun))
    end
  end

  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_summary.reset(unquote(registry),
        unquote(name), unquote(labels))
    end
  end

  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      :prometheus_summary.value(unquote(registry),
        unquote(name), unquote(labels))
    end
  end
end
