defmodule Prometheus.Metric.Histogram do

  alias Prometheus.Metric
  require Prometheus.Error

  defmacro new(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_histogram.new(unquote(spec))
      )
    end
  end

  defmacro declare(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_histogram.declare(unquote(spec))
      )
    end
  end

  defmacro observe(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_histogram.observe(unquote(registry),
          unquote(name), unquote(labels),  unquote(value))
      )
    end
  end

  defmacro dobserve(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_histogram.dobserve(unquote(registry),
          unquote(name), unquote(labels), unquote(value))
      )
    end
  end

  defmacro observe_duration(spec, fun) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_histogram.observe_duration(unquote(name),
          unquote(registry), unquote(labels), unquote(fun))
      )
    end
  end

  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_histogram.reset(unquote(registry),
          unquote(name), unquote(labels))
      )
    end
  end

  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_histogram.value(unquote(registry),
          unquote(name), unquote(labels))
      )
    end
  end
end
