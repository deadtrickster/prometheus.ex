defmodule Prometheus.Buckets do
  @moduledoc """
  Histogram buckets generators.
  """

  use Prometheus.Erlang, :prometheus_buckets

  @doc """
      iex(2)> Prometheus.Buckets.new(:default)
      [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, :infinity]  

      iex(3)> Prometheus.Buckets.new({:exponential, 100, 1.2, 3})
      [100, 120, 144, :infinity]  

      iex(2)> Prometheus.Buckets.new({:linear, 10, 5, 6})
      [10, 15, 20, 25, 30, 35, :infinity]
  """
  delegate new(arg)
end
