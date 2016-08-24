defmodule PrometheusEx.BucketsTest do
  use ExUnit.Case
  alias Prometheus.Error
  require Prometheus.Buckets
  

  test "linear buckets generator errors" do
    assert_raise Error.InvalidValue, fn ->
      Prometheus.Buckets.linear(-15, 5, 0)
    end
  end
end
