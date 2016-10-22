defmodule Prometheus.Buckets do
  @moduledoc """
  Histogram buckets generators.
  """

  use Prometheus.Erlang, :prometheus_buckets

  @doc """
  Default histogram buckets:

      iex(2)> Prometheus.Buckets.default()
      [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]

  Please note these buckets are floats and represent seconds so you'll have to use
  `Prometheus.Metric.Histogram.dobserve/2` or configure duration_unit as `:seconds`.

  """
  defmacro default do
    Erlang.call()
  end

  @doc """
  Creates `count` buckets, where the lowest bucket has an
  upper bound of `start` and each following bucket's upper bound is `factor`
  times the previous bucket's upper bound. The returned list is meant to be
  used for the `:buckets` key of histogram constructors options.

      iex(2)> Prometheus.Buckets.exponential(100, 1.2, 3)
      [100, 120, 144]

  The function raises `Prometheus.InvalidValueError` if `count` is 0 or negative,
  if `start` is 0 or negative, or if `factor` is less than or equals to 1.
  """
  defmacro exponential(start, factor, count) do
     Erlang.call([start, factor, count])
  end

  @doc """
  Creates `count` buckets, each `width` wide, where the lowest
  bucket has an upper bound of `start`. The returned list is meant to be
  used for the `:buckets` key of histogram constructors options.

      iex(2)> Prometheus.Buckets.linear(10, 5, 6)
      [10, 15, 20, 25, 30, 35]

  The function raises `Prometheus.InvalidValueError` exception
  if `count` is zero or negative.
  """
  defmacro linear(start, step, count) do
    Erlang.call([start, step, count])
  end

end
