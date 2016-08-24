defmodule Prometheus.Buckets do

  require Prometheus.Error

  defmacro default do
    :prometheus_buckets.default()
  end

  defmacro linear(start, step, count) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_buckets.linear(unquote(start), unquote(step), unquote(count))
      )
    end
  end

  defmacro exponential(start, factor, count) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_buckets.exponential(unquote(start), unquote(factor), unquote(count))
      )
    end
  end

end
