defmodule Prometheus.Metric.Summary do

  alias Prometheus.Metric
  require Prometheus.Error

  defmacro new(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.new(unquote(spec))
      )
    end
  end

  defmacro declare(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.declare(unquote(spec))
      )
    end
  end

  defmacro observe(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.observe(unquote(registry),
          unquote(name), unquote(labels),  unquote(value))
      )
    end
  end

  defmacro dobserve(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.dobserve(unquote(registry),
          unquote(name), unquote(labels), unquote(value))
      )
    end
  end

  defmacro observe_duration(spec, fun) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.observe_duration(unquote(registry),
          unquote(name), unquote(labels), unquote(fun))
      )
    end
  end

  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.reset(unquote(registry),
          unquote(name), unquote(labels))
      )
    end
  end

  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.value(unquote(registry),
          unquote(name), unquote(labels))
      )
    end
  end
end
