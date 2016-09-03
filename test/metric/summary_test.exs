defmodule Prometheus.SummaryTest do
  use Prometheus.Case

  test "registration" do
    spec = [name: :name,
            help: "",
            registry: :qwe]

    assert true == Summary.declare(spec)
    assert false == Summary.declare(spec)
    assert_raise Prometheus.Error.MFAlreadyExists,
      "Metric qwe:name already exists.",
    fn ->
      Summary.new(spec)
    end
  end

  test "spec errors" do
    assert_raise Prometheus.Error.MissingMetricSpecKey,
      "Required key name is missing from metric spec.",
    fn ->
      Summary.new([help: ""])
    end
    assert_raise Prometheus.Error.InvalidMetricName,
      "Invalid metric name: 12.",
    fn ->
      Summary.new([name: 12, help: ""])
    end
    assert_raise Prometheus.Error.InvalidMetricLabels,
      "Invalid metric labels: 12.",
    fn ->
      Summary.new([name: "qwe", labels: 12, help: ""])
    end
    assert_raise Prometheus.Error.InvalidMetricHelp,
      "Invalid metric help: 12.",
    fn ->
      Summary.new([name: "qwe", help: 12])
    end
    assert_raise Prometheus.Error.InvalidLabelName,
      "Invalid label name: quantile (summary cannot have a label named \"quantile\").",
    fn ->
      Summary.new([name: "qwe", help: "", labels: ["quantile"]])
    end
  end

  test "summary specific errors" do
    spec = [name: :http_requests_total,
            help: ""]

    ## observe
    assert_raise Prometheus.Error.InvalidValue,
      "Invalid value: qwe (observe accepts only integers).",
    fn ->
      Summary.observe(spec, "qwe")
    end
    assert_raise Prometheus.Error.InvalidValue,
      "Invalid value: 1.5 (observe accepts only integers).",
    fn ->
      Summary.observe(spec, 1.5)
    end

    ## dobserve
    assert_raise Prometheus.Error.InvalidValue,
      "Invalid value: qwe (dobserve accepts only numbers).",
    fn ->
      Summary.dobserve(spec, "qwe")
    end

    ## observe_duration
    assert_raise Prometheus.Error.InvalidValue,
      "Invalid value: qwe (observe_duration accepts only functions).",
    fn ->
      Summary.observe_duration(spec, "qwe")
    end
  end

  test "mf/arity errors" do
    spec = [name: :metric_with_label,
            labels: [:label],
            help: ""]
    Summary.declare(spec)

    ## observe
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Summary.observe(:unknown_metric, 1)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Summary.observe([name: :metric_with_label, labels: [:l1, :l2]], 1)
    end

    ## dobserve
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Summary.dobserve(:unknown_metric)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Summary.dobserve([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## observe_duration
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Summary.observe_duration(:unknown_metric, fn -> 1 end)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Summary.observe_duration([name: :metric_with_label, labels: [:l1, :l2]], fn -> 1 end)
    end

    ## remove
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Summary.remove(:unknown_metric)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Summary.remove([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## reset
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Summary.reset(:unknown_metric)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Summary.reset([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## value
    assert_raise Prometheus.Error.UnknownMetric,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Summary.value(:unknown_metric)
    end
    assert_raise Prometheus.Error.InvalidMetricArity,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Summary.value([name: :metric_with_label, labels: [:l1, :l2]])
    end
  end

  test "observe" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    Summary.new(spec)

    Summary.observe(spec)
    Summary.observe(spec, 3)
    assert {2, 4} == Summary.value(spec)

    Summary.reset(spec)

    assert {0, 0} == Summary.value(spec)
  end

  test "dobserve" do
    spec = [name: :http_requests_total,
            help: ""]
    Summary.new(spec)

    Summary.dobserve(spec)
    Summary.dobserve(spec, 3.5)

    ## dobserve is async so lets make sure gen_server processed our increment request
    Process.sleep(10)
    assert {2, 4.5} == Summary.value(spec)

    Summary.reset(spec)

    assert {0, 0} == Summary.value(spec)
  end

  test "observe_duration" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    Summary.new(spec)

    assert 1 == Summary.observe_duration(spec, fn ->
      Process.sleep(1000)
      1
    end)

    ## observe_duration is async so lets make sure gen_server processed our increment request
    Process.sleep(10)
    {count, sum} = Summary.value(spec)
    assert 1 == count
    assert 1 < sum and sum < 1.2

    assert_raise ErlangError, fn ->
      Summary.observe_duration(spec, fn ->
        :erlang.error({:qwe})
      end)
    end

    ## observe_duration is async so lets make sure gen_server processed our increment request
    Process.sleep(10)
    {count, sum} = Summary.value(spec)
    assert 2 == count
    assert 1 < sum and sum < 1.2
  end

  test "undefined value" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    Summary.new(spec)

    assert :undefined == Summary.value(spec)
  end

  test "remove" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    wl_spec = [name: :simple_summary,
               help: ""]

    Summary.new(spec)
    Summary.new(wl_spec)

    Summary.observe(spec)
    Summary.observe(wl_spec)

    assert {1, 1} == Summary.value(spec)
    assert {1, 1} == Summary.value(wl_spec)

    assert true == Summary.remove(spec)
    assert true == Summary.remove(wl_spec)

    assert :undefined == Summary.value(spec)
    assert :undefined == Summary.value(wl_spec)

    assert false == Summary.remove(spec)
    assert false == Summary.remove(wl_spec)
  end

end