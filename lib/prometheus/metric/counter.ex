defmodule Prometheus.Metric.Counter do

  alias Prometheus.Metric
  require Prometheus.Error

  defmacro new(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.new(unquote(spec))
      )
    end
  end

  defmacro declare(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.declare(unquote(spec))
      )
    end
  end

  defmacro inc(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.inc(unquote(registry), unquote(name), unquote(labels),  unquote(value))
      )
    end
  end

  defmacro dinc(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.dinc(unquote(registry), unquote(name), unquote(labels),  unquote(value))
      )
    end
  end

  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.reset(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end

  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.value(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end
end
