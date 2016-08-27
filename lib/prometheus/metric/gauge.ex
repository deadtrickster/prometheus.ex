defmodule Prometheus.Metric.Gauge do

  alias Prometheus.Metric
  require Prometheus.Error

  defmacro new(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.new(unquote(spec))
      )
    end
  end

  defmacro declare(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.declare(unquote(spec))
      )
    end
  end

  defmacro set(spec, value) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.set(unquote(registry), unquote(name), unquote(labels),  unquote(value))
      )
    end
  end

  defmacro set_to_current_time(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.set_to_current_time(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end

  defmacro track_inprogress(spec, fun) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.track_inprogress(unquote(registry), unquote(name), unquote(labels), unquote(fun))
      )
    end
  end

  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.reset(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end

  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.value(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end
end
