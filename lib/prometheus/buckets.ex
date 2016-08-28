defmodule Prometheus.Buckets do
  @moduledoc """
  Histogram buckets generators.
  """

  require Prometheus.Error

  @doc """
  Default histogram buckets:

      iex(2)> Prometheus.Buckets.default()
      [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]

  Please note these buckets are floats so you'll have to use `Prometheus.Metric.Histogram.dobserve/2`.

  """
  defmacro default do
    :prometheus_buckets.default()
  end

  @doc """
  Creates `count` buckets, each `width` wide, where the lowest
  bucket has an upper bound of `start`. The returned list is meant to be
  used for the `:buckets` key of histogram constructors options.

      iex(2)> Prometheus.Buckets.linear(10, 5, 6)
      [10, 15, 20, 25, 30, 35]

  The function raises `Prometheus.Error.InvalidValue` exception if `count` is zero or negative.
  """
  defmacro linear(start, step, count) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_buckets.linear(unquote(start), unquote(step), unquote(count))
      )
    end
  end

  @doc """
  Creates `count` buckets, where the lowest bucket has an
  upper bound of `start` and each following bucket's upper bound is `factor`
  times the previous bucket's upper bound. The returned list is meant to be
  used for the `:buckets` key of histogram constructors options.

  The function raises `Prometheus.Error.InvalidValue` if `count` is 0 or negative,
  if `start` is 0 or negative, or if `factor` is less than or equal 1.
  """
  defmacro exponential(start, factor, count) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_buckets.exponential(unquote(start), unquote(factor), unquote(count))
      )
    end
  end

end
