defmodule Prometheus.CounterTest do
  use Prometheus.Case

  test "registration" do
    spec = [name: :http_requests_total,
            help: "",
            registry: :qwe]

    assert true == Counter.declare(spec)
    assert false == Counter.declare(spec)
    assert_raise Prometheus.Error.MFAlreadyExists, "Metric qwe:http_requests_total already exists.",
    fn ->
      Counter.new(spec)
    end
  end

  test "errors" do
    ## spec errors
    assert_raise Prometheus.Error.InvalidMetricName, "Invalid metric name: 12.",
    fn ->
      Counter.new([name: 12, help: ""])
    end
    assert_raise Prometheus.Error.InvalidMetricLabels, "Invalid metric labels: 12.",
    fn ->
      Counter.new([name: "qwe", labels: 12, help: ""])
    end
    assert_raise Prometheus.Error.InvalidMetricHelp, "Invalid metric help: 12.",
    fn ->
      Counter.new([name: "qwe", help: 12])
    end
    ## counter specific errors
    spec = [name: :http_requests_total,
            help: ""]
    Counter.declare(spec)
    assert_raise Prometheus.Error.InvalidValue, "Invalid value: -1 (inc accepts only non-negative integers).",
    fn ->
      Counter.inc(spec, -1)
    end
    assert_raise Prometheus.Error.InvalidValue, "Invalid value: -1 (inc accepts only non-negative integers).",
    fn ->
      Counter.inc(spec, -1.5)
    end
  end

end
