defmodule Prometheus.BooleanTest do
  use Prometheus.Case

  test "registration" do
    spec = [name: :name, help: "", registry: :qwe]

    assert true == Boolean.declare(spec)
    assert false == Boolean.declare(spec)

    assert_raise Prometheus.MFAlreadyExistsError, "Metric qwe:name already exists.", fn ->
      Boolean.new(spec)
    end
  end

  test "spec errors" do
    assert_raise Prometheus.MissingMetricSpecKeyError,
                 "Required key name is missing from metric spec.",
                 fn ->
                   Boolean.new(help: "")
                 end

    assert_raise Prometheus.InvalidMetricNameError, "Invalid metric name: 12.", fn ->
      Boolean.new(name: 12, help: "")
    end

    assert_raise Prometheus.InvalidMetricLabelsError, "Invalid metric labels: 12.", fn ->
      Boolean.new(name: "qwe", labels: 12, help: "")
    end

    assert_raise Prometheus.InvalidMetricHelpError, "Invalid metric help: 12.", fn ->
      Boolean.new(name: "qwe", help: 12)
    end
  end

  test "boolean specific errors" do
    spec = [name: :fuse_state, labels: [:qwe], help: ""]

    Boolean.declare(spec)

    ## set
    assert_raise Prometheus.InvalidValueError,
                 "Invalid value: %{} (value is not boolean).",
                 fn ->
                   Boolean.set(spec, %{})
                 end

    ## toggle

    Boolean.set(spec, :undefined)

    assert_raise Prometheus.InvalidValueError,
                 "Invalid value: :undefined (can't toggle undefined boolean).",
                 fn ->
                   Boolean.toggle(spec)
                 end
  end

  test "mf/arity errors" do
    spec = [name: :metric_with_label, labels: [:label], help: ""]
    Boolean.declare(spec)

    ## set
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Boolean.set(:unknown_metric, true)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Boolean.set([name: :metric_with_label, labels: [:l1, :l2]], true)
                 end

    ## toggle
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Boolean.toggle(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Boolean.toggle(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## remove
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Boolean.remove(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Boolean.remove(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## reset
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Boolean.reset(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Boolean.reset(name: :metric_with_label, labels: [:l1, :l2])
                 end

    ## value
    assert_raise Prometheus.UnknownMetricError,
                 "Unknown metric {registry: default, name: unknown_metric}.",
                 fn ->
                   Boolean.value(:unknown_metric)
                 end

    assert_raise Prometheus.InvalidMetricArityError,
                 "Invalid metric arity: got 2, expected 1.",
                 fn ->
                   Boolean.value(name: :metric_with_label, labels: [:l1, :l2])
                 end
  end

  test "set" do
    spec = [name: :fuse_state, labels: [:name], help: ""]
    Boolean.new(spec)

    Boolean.set(spec, 110)
    assert true == Boolean.value(spec)
    Boolean.set(spec, 0)
    assert false == Boolean.value(spec)
    Boolean.set(spec, true)
    assert true == Boolean.value(spec)
    Boolean.set(spec, false)
    assert false == Boolean.value(spec)
    Boolean.set(spec, [1])
    assert true == Boolean.value(spec)
    Boolean.set(spec, [])
    assert false == Boolean.value(spec)
    Boolean.reset(spec)
    assert false == Boolean.value(spec)
  end

  test "toggle" do
    spec = [name: :fuse_state, labels: [:name], help: ""]
    Boolean.new(spec)

    Boolean.set(spec, 110)
    assert true == Boolean.value(spec)
    Boolean.toggle(spec)
    assert false == Boolean.value(spec)
    Boolean.toggle(spec)
    assert true == Boolean.value(spec)
  end

  test "remove" do
    fuse_state = [name: :fuse_state, labels: [:name], help: ""]
    Boolean.new(fuse_state)

    simple_boolean = [name: :simple_boolean, labels: [], help: ""]
    Boolean.new(simple_boolean)

    Boolean.set(fuse_state, true)
    Boolean.set(simple_boolean, true)

    assert true == Boolean.value(fuse_state)
    assert true == Boolean.value(simple_boolean)

    assert true == Boolean.remove(fuse_state)
    assert true == Boolean.remove(simple_boolean)

    assert :undefined == Boolean.value(fuse_state)
    assert :undefined == Boolean.value(simple_boolean)

    assert false == Boolean.remove(fuse_state)
    assert false == Boolean.remove(simple_boolean)
  end

  test "default value" do
    fuse_state = [name: :fuse_state, labels: [:name], help: ""]
    Boolean.new(fuse_state)

    simple_boolean = [name: :simple_boolean, labels: [], help: ""]
    Boolean.new(simple_boolean)

    assert :undefined == Boolean.value(fuse_state)
    assert :undefined == Boolean.value(simple_boolean)
  end
end
