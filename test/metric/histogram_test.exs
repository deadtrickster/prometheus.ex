defmodule Prometheus.HistogramTest do
  use Prometheus.Case

  test "registration" do
    spec = [name: :name,
            help: "",
            registry: :qwe]

    assert true == Histogram.declare(spec)
    assert false == Histogram.declare(spec)
    assert_raise Prometheus.Error.MFAlreadyExists,
      "Metric qwe:name already exists.",
    fn ->
      Histogram.new(spec)
    end
  end

  test "spec errors" do
    assert_raise Prometheus.Error.MissingMetricSpecKey,
      "Required key name is missing from metric spec.",
    fn ->
      Histogram.new([help: ""])
    end
    assert_raise Prometheus.Error.InvalidMetricName,
      "Invalid metric name: 12.",
    fn ->
      Histogram.new([name: 12, help: ""])
    end
    assert_raise Prometheus.Error.InvalidMetricLabels,
      "Invalid metric labels: 12.",
    fn ->
      Histogram.new([name: "qwe", labels: 12, help: ""])
    end
    assert_raise Prometheus.Error.InvalidMetricHelp,
      "Invalid metric help: 12.",
    fn ->
      Histogram.new([name: "qwe", help: 12])
    end
    assert_raise Prometheus.Error.InvalidLabelName,
      "Invalid label name: le (histogram cannot have a label named \"le\").",
    fn ->
      Histogram.new([name: "qwe", help: "", labels: ["le"]])
    end
    ## buckets
    assert_raise Prometheus.Error.HistogramNoBuckets,
      "Invalid histogram buckets: .",
    fn ->
      Histogram.new([name: "qwe", help: "", buckets: []])
    end
    assert_raise Prometheus.Error.HistogramNoBuckets,
      "Invalid histogram buckets: undefined.",
    fn ->
      Histogram.new([name: "qwe", help: "", buckets: :undefined])
    end
    assert_raise Prometheus.Error.HistogramInvalidBuckets,
      "Invalid histogram buckets: 1 (not a list).",
    fn ->
      Histogram.new([name: "qwe", help: "", buckets: 1])
    end
    assert_raise Prometheus.Error.HistogramInvalidBuckets,
      "Invalid histogram buckets: [1,3,2] (buckets not sorted).",
    fn ->
      Histogram.new([name: "qwe", help: "", buckets: [1, 3, 2]])
    end
    assert_raise Prometheus.Error.HistogramInvalidBound,
      "Invalid histogram bound: qwe.",
    fn ->
      Histogram.new([name: "qwe", help: "", buckets: ["qwe"]])
    end
  end

  test "histogram specific errors" do
    spec = [name: :http_requests_total,
            help: ""]

    ## observe
    assert_raise Prometheus.Error.InvalidValue,
      "Invalid value: qwe (observe accepts only integers).",
    fn ->
      Histogram.observe(spec, "qwe")
    end
    assert_raise Prometheus.Error.InvalidValue,
      "Invalid value: 1.5 (observe accepts only integers).",
    fn ->
      Histogram.observe(spec, 1.5)
    end

    ## dobserve
    assert_raise Prometheus.Error.InvalidValue,
      "Invalid value: qwe (dobserve accepts only numbers).",
    fn ->
      Histogram.dobserve(spec, "qwe")
    end

    ## observe_duration
    assert_raise Prometheus.Error.InvalidValue,
      "Invalid value: qwe (observe_duration accepts only functions).",
    fn ->
      Histogram.observe_duration(spec, "qwe")
    end
  end

  test "mf/arity errors" do
    spec = [name: :metric_with_label,
            labels: [:label],
            help: ""]
    Histogram.declare(spec)

    ## observe
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Histogram.observe(:unknown_metric, 1)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Histogram.observe([name: :metric_with_label, labels: [:l1, :l2]], 1)
    end

    ## dobserve
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Histogram.dobserve(:unknown_metric)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Histogram.dobserve([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## observe_duration
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Histogram.observe_duration(:unknown_metric, fn -> 1 end)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Histogram.observe_duration([name: :metric_with_label, labels: [:l1, :l2]], fn -> 1 end)
    end

    ## remove
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Histogram.remove(:unknown_metric)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Histogram.remove([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## reset
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Histogram.reset(:unknown_metric)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Histogram.reset([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## value
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Histogram.value(:unknown_metric)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Histogram.value([name: :metric_with_label, labels: [:l1, :l2]])
    end
  end

  test "observe" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    Histogram.new(spec)

    Histogram.observe(spec)
    Histogram.observe(spec, 3)
    assert {[0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0], 4} == Histogram.value(spec)

    Histogram.reset(spec)

    assert {[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0} == Histogram.value(spec)
  end

  test "dobserve" do
    spec = [name: :http_requests_total,
            help: ""]
    Histogram.new(spec)

    Histogram.dobserve(spec)
    Histogram.dobserve(spec, 3.5)

    ## dobserve is async so lets make sure gen_server processed our increment request
    Process.sleep(10)
    assert {[0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0], 4.5} == Histogram.value(spec)

    Histogram.reset(spec)

    assert {[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 0} == Histogram.value(spec)
  end

  test "observe_duration" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    Histogram.new(spec)

    assert 1 == Histogram.observe_duration(spec, fn ->
      Process.sleep(1000)
      1
    end)

    ## observe_duration is async so lets make sure gen_server processed our increment request
    Process.sleep(10)
    {buckets, sum} = Histogram.value(spec)
    assert [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0] == buckets
    assert 1 < sum and sum < 1.2

    assert_raise ErlangError, fn ->
      Histogram.observe_duration(spec, fn ->
        :erlang.error({:qwe})
      end)
    end

    ## observe_duration is async so lets make sure gen_server processed our increment request
    Process.sleep(10)
    {buckets, sum} = Histogram.value(spec)
    assert [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0] == buckets
    assert 1 < sum and sum < 1.2
  end

  test "undefined value" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    Histogram.new(spec)

    assert :undefined == Histogram.value(spec)
  end

  test "remove" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    wl_spec = [name: :simple_histogram,
               help: ""]

    Histogram.new(spec)
    Histogram.new(wl_spec)

    Histogram.observe(spec)
    Histogram.observe(wl_spec)

    assert {[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], 1} == Histogram.value(spec)
    assert {[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0], 1} == Histogram.value(wl_spec)

    assert true == Histogram.remove(spec)
    assert true == Histogram.remove(wl_spec)

    assert :undefined == Histogram.value(spec)
    assert :undefined == Histogram.value(wl_spec)

    assert false == Histogram.remove(spec)
    assert false == Histogram.remove(wl_spec)
  end

end
