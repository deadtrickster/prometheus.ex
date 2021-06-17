defmodule Prometheus.QuantileSummaryTest do
  use Prometheus.Case

  test "registration" do
    spec = [name: :name, help: "", registry: :qwe]

    assert true == QuantileSummary.declare(spec)
    assert false == QuantileSummary.declare(spec)

    assert_raise Prometheus.MFAlreadyExistsError, "Metric qwe:name already exists.", fn ->
      QuantileSummary.new(spec)
    end
  end

  test "spec errors" do
    assert_raise Prometheus.MissingMetricSpecKeyError,
                 "Required key name is missing from metric spec.",
                 fn ->
                   QuantileSummary.new(help: "")
                 end

    assert_raise Prometheus.InvalidMetricNameError, "Invalid metric name: 12.", fn ->
      QuantileSummary.new(name: 12, help: "")
    end

    assert_raise Prometheus.InvalidMetricLabelsError, "Invalid metric labels: 12.", fn ->
      QuantileSummary.new(name: "qwe", labels: 12, help: "")
    end

    assert_raise Prometheus.InvalidMetricHelpError, "Invalid metric help: 12.", fn ->
      QuantileSummary.new(name: "qwe", help: 12)
    end

    assert_raise Prometheus.InvalidLabelNameError,
                 "Invalid label name: quantile (summary cannot have a label named \"quantile\").",
                 fn ->
                   QuantileSummary.new(name: "qwe", help: "", labels: ["quantile"])
                 end
  end

  test "summary specific errors" do
    spec = [name: :http_requests_total, help: ""]

    ## observe
    assert_raise Prometheus.InvalidValueError,
                 "Invalid value: \"qwe\" (observe accepts only numbers).",
                 fn ->
                   QuantileSummary.observe(spec, "qwe")
                 end

    ## observe_duration TODO: assert_compile_time_raise
    assert_raise Prometheus.InvalidBlockArityError,
                 "Fn with arity 2 (args: :x, :y) passed as block.",
                 fn ->
                   Macro.expand(
                     quote do
                       QuantileSummary.observe_duration(spec, fn x, y -> 1 + x + y end)
                     end,
                     __ENV__
                   )
                 end
  end

  test "mf/arity errors" do
    spec = [name: :metric_with_label, labels: [:label], help: ""]
    QuantileSummary.declare(spec)

    ## observe
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   QuantileSummary.observe(:unknown_metric, 1)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   QuantileSummary.observe(
                     [name: :metric_with_label, labels: [:l1, :l2]],
                     1
                   )
                 end

    ## observe_duration
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   QuantileSummary.observe_duration(:unknown_metric, fn -> 1 end)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   QuantileSummary.observe_duration(
                     [name: :metric_with_label, labels: [:l1, :l2]],
                     fn -> 1 end
                   )
                 end

    ## remove
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   QuantileSummary.remove(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   QuantileSummary.remove(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## reset
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   QuantileSummary.reset(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   QuantileSummary.reset(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## value
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   QuantileSummary.value(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   QuantileSummary.value(name: :metric_with_label, labels: [:l1, :l2])
                 end
  end

  test "observe" do
    spec = [name: :http_requests_total, labels: [:method], help: ""]
    QuantileSummary.new(spec)

    QuantileSummary.observe(spec)
    QuantileSummary.observe(spec, 3)
    QuantileSummary.observe(spec)
    QuantileSummary.observe(spec, 3.5)

    {count, summary, quantiles} = QuantileSummary.value(spec)
    assert {4, 8.5} == {count, summary}
    assert {0.5, 3} == List.keyfind(quantiles, 0.5, 0)
    assert {0.9, 3.5} == List.keyfind(quantiles, 0.9, 0)
    assert {0.95, 3.5} == List.keyfind(quantiles, 0.95, 0)

    QuantileSummary.reset(spec)

    assert {0, 0, []} == QuantileSummary.value(spec)
  end

  test "observe_duration fn" do
    spec = [name: :duration_seconds, labels: [:method], help: ""]
    QuantileSummary.new(spec)

    assert 1 ==
             QuantileSummary.observe_duration(spec, fn ->
               Process.sleep(1000)
               1
             end)

    ## observe_duration is async. let's make sure gen_server processed our request
    Process.sleep(10)
    {count, sum, _quantiles} = QuantileSummary.value(spec)
    assert 1 == count
    assert 1 < sum and sum < 1.2

    assert_raise ErlangError, fn ->
      QuantileSummary.observe_duration(spec, fn ->
        :erlang.error({:qwe})
      end)
    end

    ## observe_duration is async. let's make sure gen_server processed our request
    Process.sleep(10)
    {count, sum, quantiles} = QuantileSummary.value(spec)
    assert 2 == count
    assert 1 < sum and sum < 1.2
  end

  test "observe_duration block" do
    spec = [name: :duration_seconds, labels: [:method], help: ""]
    QuantileSummary.new(spec)

    assert :ok == QuantileSummary.observe_duration(spec, do: Process.sleep(1000))

    ## observe_duration is async. let's make sure gen_server processed our request
    Process.sleep(10)
    {count, sum, quantiles} = QuantileSummary.value(spec)
    assert 1 == count
    assert 1 < sum and sum < 1.2

    {_, median} = List.keyfind(quantiles, 0.5, 0)
    assert 1_000_000_000 < median and median < 1_200_000_000

    assert_raise ErlangError, fn ->
      QuantileSummary.observe_duration spec do
        :erlang.error({:qwe})
      end
    end

    ## observe_duration is async. let's make sure gen_server processed our request
    Process.sleep(10)
    {count, sum, quantiles} = QuantileSummary.value(spec)
    assert 2 == count
    assert 1 < sum and sum < 1.2
  end

  test "remove" do
    spec = [name: :http_requests_total, labels: [:method], help: ""]
    wl_spec = [name: :simple_summary, help: ""]

    QuantileSummary.new(spec)
    QuantileSummary.new(wl_spec)

    QuantileSummary.observe(spec)
    QuantileSummary.observe(wl_spec)

    assert {1, 1, [{0.5, 1}, {0.9, 1}, {0.95, 1}]} == QuantileSummary.value(spec)
    assert {1, 1, [{0.5, 1}, {0.9, 1}, {0.95, 1}]} == QuantileSummary.value(wl_spec)

    assert true == QuantileSummary.remove(spec)
    assert true == QuantileSummary.remove(wl_spec)

    assert :undefined == QuantileSummary.value(spec)
    assert :undefined == QuantileSummary.value(wl_spec)

    assert false == QuantileSummary.remove(spec)
    assert false == QuantileSummary.remove(wl_spec)
  end

  test "undefined value" do
    lspec = [name: :orders_summary, labels: [:department], help: ""]
    QuantileSummary.new(lspec)

    assert :undefined == QuantileSummary.value(lspec)

    spec = [name: :something_summary, labels: [], help: ""]
    QuantileSummary.new(spec)

    assert {0, 0, []} == QuantileSummary.value(spec)
  end
end
