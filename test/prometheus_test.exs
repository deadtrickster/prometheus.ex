defmodule PrometheusExTest do
  use ExUnit.Case
  doctest Prometheus.Buckets
  doctest Prometheus.Contrib.HTTP
  doctest Prometheus.Config
  doctest Prometheus.Model

  test "the truth" do
    assert 1 + 1 == 2
  end
end
