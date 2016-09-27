defmodule Prometheus.BucketsTest do
  use ExUnit.Case

  use Prometheus
  
  doctest Prometheus.Buckets

  test "linear buckets generator tests" do
    assert_raise Prometheus.InvalidValueError, fn ->
      Prometheus.Buckets.linear(-15, 5, 0)
    end

    assert [-15, -10, -5, 0, 5, 10] == Prometheus.Buckets.linear(-15, 5, 6)
  end

  test "exponential buckets generator tests" do
    assert_raise Prometheus.InvalidValueError, fn ->
      Prometheus.Buckets.exponential(-15, 5, 0)
    end
    assert_raise Prometheus.InvalidValueError, fn ->
      Prometheus.Buckets.exponential(-15, 5, 2)
    end
    assert_raise Prometheus.InvalidValueError, fn ->
      Prometheus.Buckets.exponential(15, 0.5, 3)
    end

    assert [100, 120, 144] == Prometheus.Buckets.exponential(100, 1.2, 3)
  end

  test "default buckets test" do
    assert [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10] == Prometheus.Buckets.default
  end
end
