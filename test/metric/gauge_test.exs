defmodule Prometheus.GaugeTest do
  use Prometheus.Case

  test "registration" do
    spec = [name: :name, help: "", registry: :qwe]

    assert true == Gauge.declare(spec)
    assert false == Gauge.declare(spec)

    assert_raise Prometheus.MFAlreadyExistsError, "Metric qwe:name already exists.", fn ->
      Gauge.new(spec)
    end
  end

  test "spec errors" do
    assert_raise Prometheus.MissingMetricSpecKeyError,
                 "Required key name is missing from metric spec.",
                 fn ->
                   Gauge.new(help: "")
                 end

    assert_raise Prometheus.InvalidMetricNameError, "Invalid metric name: 12.", fn ->
      Gauge.new(name: 12, help: "")
    end

    assert_raise Prometheus.InvalidMetricLabelsError, "Invalid metric labels: 12.", fn ->
      Gauge.new(name: "qwe", labels: 12, help: "")
    end

    assert_raise Prometheus.InvalidMetricHelpError, "Invalid metric help: 12.", fn ->
      Gauge.new(name: "qwe", help: 12)
    end
  end

  test "gauge specific errors" do
    spec = [name: :http_requests_total, help: ""]

    ## set
    assert_raise Prometheus.InvalidValueError,
                 "Invalid value: \"qwe\" (set accepts only numbers and 'undefined').",
                 fn ->
                   Gauge.set(spec, "qwe")
                 end

    ## inc
    assert_raise Prometheus.InvalidValueError,
                 "Invalid value: \"qwe\" (inc accepts only numbers).",
                 fn ->
                   Gauge.inc(spec, "qwe")
                 end

    ## dec
    assert_raise Prometheus.InvalidValueError,
                 "Invalid value: \"qwe\" (dec accepts only numbers).",
                 fn ->
                   Gauge.dec(spec, "qwe")
                 end

    ## track_inprogress
    assert_raise Prometheus.InvalidBlockArityError,
                 "Fn with arity 2 (args: :x, :y) passed as block.",
                 fn ->
                   Macro.expand(
                     quote do
                       Gauge.track_inprogress(spec, fn x, y -> 1 + x + y end)
                     end,
                     __ENV__
                   )
                 end

    ## set_duration
    assert_raise Prometheus.InvalidBlockArityError,
                 "Fn with arity 2 (args: :x, :y) passed as block.",
                 fn ->
                   Macro.expand(
                     quote do
                       Gauge.set_duration(spec, fn x, y -> 1 + x + y end)
                     end,
                     __ENV__
                   )
                 end
  end

  test "mf/arity errors" do
    spec = [name: :metric_with_label, labels: [:label], help: ""]
    Gauge.declare(spec)

    ## set
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.set(:unknown_metric, 1)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.set([name: :metric_with_label, labels: [:l1, :l2]], 1)
                 end

    ## inc
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.inc(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.inc(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## dec
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.dec(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.dec(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## set_to_current_time
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.set_to_current_time(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.set_to_current_time(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## track_inprogress
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.track_inprogress(:unknown_metric, fn -> 1 end)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.track_inprogress(
                     [name: :metric_with_label, labels: [:l1, :l2]],
                     fn -> 1 end
                   )
                 end

    ## set_duration
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.set_duration(:unknown_metric, fn -> 1 end)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.set_duration(
                     [name: :metric_with_label, labels: [:l1, :l2]],
                     fn -> 1 end
                   )
                 end

    ## remove
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.remove(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.remove(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## reset
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.reset(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.reset(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## value
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Gauge.value(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Gauge.value(name: :metric_with_label, labels: [:l1, :l2])
                 end
  end

  test "set" do
    spec = [name: :metric_with_label, labels: [:label], help: ""]
    Gauge.declare(spec)

    Gauge.set(spec, 100)
    assert 100 == Gauge.value(spec)

    Gauge.set(spec, 105)
    assert 105 == Gauge.value(spec)

    Gauge.reset(spec)
    assert 0 == Gauge.value(spec)
  end

  test "inc" do
    spec = [name: :http_requests_total, labels: [:method], help: ""]
    Gauge.new(spec)

    Gauge.inc(spec)
    Gauge.inc(spec, 3)
    Gauge.inc(spec)
    Gauge.inc(spec, 3.5)
    assert 8.5 == Gauge.value(spec)

    Gauge.reset(spec)

    assert 0 == Gauge.value(spec)
  end

  test "dec" do
    spec = [name: :http_requests_total, labels: [:method], help: ""]
    Gauge.new(spec)

    Gauge.dec(spec)
    Gauge.dec(spec, 3)
    Gauge.dec(spec)
    Gauge.dec(spec, 3.5)

    assert (-8.5 == Gauge.value(spec))

    Gauge.reset(spec)

    assert 0 == Gauge.value(spec)
  end

  test "set_to_current_time" do
    spec = [name: :http_requests_total, labels: [:method], help: ""]
    Gauge.new(spec)

    Gauge.set_to_current_time(spec)

    assert :os.system_time(:seconds) == Gauge.value(spec)
  end

  test "test_track_inprogress fn" do
    spec = [name: :http_requests_total, labels: [:method], help: ""]
    Gauge.new(spec)

    assert 1 ==
             Gauge.track_inprogress(spec, fn ->
               Gauge.value(spec)
             end)

    assert_raise ErlangError, fn ->
      Gauge.track_inprogress(spec, fn ->
        :erlang.error({:qwe})
      end)
    end

    assert 0 = Gauge.value(spec)
  end

  test "test_track_inprogress block" do
    spec = [name: :http_requests_total, labels: [:method], help: ""]
    Gauge.new(spec)

    assert 1 == Gauge.track_inprogress(spec, do: Gauge.value(spec))

    assert_raise ErlangError, fn ->
      Gauge.track_inprogress spec do
        :erlang.error({:qwe})
      end
    end

    assert 0 = Gauge.value(spec)
  end

  test "set_duration fn" do
    spec = [
      name: :http_requests_total,
      labels: [:method],
      help: "",
      duration_unit: :seconds
    ]

    Gauge.new(spec)

    assert 1 ==
             Gauge.set_duration(spec, fn ->
               Process.sleep(1000)
               1
             end)

    assert 1 < Gauge.value(spec) and Gauge.value(spec) < 1.2

    assert_raise ErlangError, fn ->
      Gauge.set_duration(spec, fn ->
        :erlang.error({:qwe})
      end)
    end

    assert 0.0 < Gauge.value(spec) and Gauge.value(spec) < 0.2
  end

  test "set_duration block" do
    spec = [
      name: :http_requests_total,
      labels: [:method],
      help: "",
      duration_unit: :seconds
    ]

    Gauge.new(spec)

    assert :ok == Gauge.set_duration(spec, do: Process.sleep(1000))

    assert 1 < Gauge.value(spec) and Gauge.value(spec) < 1.2

    assert_raise ErlangError, fn ->
      Gauge.set_duration spec do
        :erlang.error({:qwe})
      end
    end

    assert 0.0 < Gauge.value(spec) and Gauge.value(spec) < 0.2
  end

  test "remove" do
    spec = [name: :http_requests_total, labels: [:method], help: ""]
    wl_spec = [name: :simple_gauge, help: ""]

    Gauge.new(spec)
    Gauge.new(wl_spec)

    Gauge.inc(spec)
    Gauge.inc(wl_spec)

    assert 1 == Gauge.value(spec)
    assert 1 == Gauge.value(wl_spec)

    assert true == Gauge.remove(spec)
    assert true == Gauge.remove(wl_spec)

    assert :undefined == Gauge.value(spec)
    assert :undefined == Gauge.value(wl_spec)

    assert false == Gauge.remove(spec)
    assert false == Gauge.remove(wl_spec)
  end

  test "default value" do
    lspec = [name: :http_requests_gauge, labels: [:method], help: ""]
    Gauge.new(lspec)

    assert :undefined == Gauge.value(lspec)

    spec = [name: :something_gauge, labels: [], help: ""]
    Gauge.new(spec)

    assert 0 == Gauge.value(spec)
  end
end
