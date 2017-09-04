defmodule Prometheus.CounterTest do
  use Prometheus.Case

  test "registration" do
    spec = [name: :name,
            help: "",
            registry: :qwe]

    assert true == Counter.declare(spec)
    assert false == Counter.declare(spec)
    assert_raise Prometheus.MFAlreadyExistsError,
      "Metric qwe:name already exists.",
    fn ->
      Counter.new(spec)
    end
  end

  test "spec errors" do
    assert_raise Prometheus.MissingMetricSpecKeyError,
      "Required key name is missing from metric spec.",
    fn ->
      Counter.new([help: ""])
    end
    assert_raise Prometheus.InvalidMetricNameError,
      "Invalid metric name: 12.",
    fn ->
      Counter.new([name: 12, help: ""])
    end
    assert_raise Prometheus.InvalidMetricLabelsError,
      "Invalid metric labels: 12.",
    fn ->
      Counter.new([name: "qwe", labels: 12, help: ""])
    end
    assert_raise Prometheus.InvalidMetricHelpError,
      "Invalid metric help: 12.",
    fn ->
      Counter.new([name: "qwe", help: 12])
    end
  end

  test "counter specific errors" do
    spec = [name: :http_requests_total,
            help: ""]

    ## inc
    assert_raise Prometheus.InvalidValueError,
      "Invalid value: -1 (inc accepts only non-negative integers).",
    fn ->
      Counter.inc(spec, -1)
    end
    assert_raise Prometheus.InvalidValueError,
      "Invalid value: 1.5 (inc accepts only non-negative integers).",
    fn ->
      Counter.inc(spec, 1.5)
    end
    assert_raise Prometheus.InvalidValueError,
      "Invalid value: \"qwe\" (inc accepts only non-negative integers).",
    fn ->
      Counter.inc(spec, "qwe")
    end

    ## dinc
    assert_raise Prometheus.InvalidValueError,
      "Invalid value: -1 (dinc accepts only non-negative numbers).",
    fn ->
      Counter.dinc(spec, -1)
    end
    assert_raise Prometheus.InvalidValueError,
      "Invalid value: \"qwe\" (dinc accepts only non-negative numbers).",
    fn ->
      Counter.dinc(spec, "qwe")
    end
  end

  test "mf/arity errors" do
    spec = [name: :metric_with_label,
            labels: [:label],
            help: ""]
    Counter.declare(spec)

    ## inc
    assert_raise Prometheus.UnknownMetricError,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Counter.inc(:unknown_metric)
    end
    assert_raise Prometheus.InvalidMetricArityError,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Counter.inc([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## dinc
    assert_raise Prometheus.UnknownMetricError,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Counter.dinc(:unknown_metric)
    end
    assert_raise Prometheus.InvalidMetricArityError,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Counter.dinc([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## remove
    assert_raise Prometheus.UnknownMetricError,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Counter.remove(:unknown_metric)
    end
    assert_raise Prometheus.InvalidMetricArityError,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Counter.remove([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## reset
    assert_raise Prometheus.UnknownMetricError,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Counter.reset(:unknown_metric)
    end
    assert_raise Prometheus.InvalidMetricArityError,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Counter.reset([name: :metric_with_label, labels: [:l1, :l2]])
    end

    ## value
    assert_raise Prometheus.UnknownMetricError,
      "Unknown metric {registry: default, name: unknown_metric}.",
    fn ->
      Counter.value(:unknown_metric)
    end
    assert_raise Prometheus.InvalidMetricArityError,
      "Invalid metric arity: got 2, expected 1.",
    fn ->
      Counter.value([name: :metric_with_label, labels: [:l1, :l2]])
    end
  end

  test "inc" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    Counter.new(spec)

    Counter.inc(spec)
    Counter.inc(spec, 3)
    assert 4 == Counter.value(spec)

    Counter.reset(spec)

    assert 0 == Counter.value(spec)
  end

  test "dinc" do
    spec = [name: :http_requests_total,
            help: ""]
    Counter.new(spec)

    Counter.dinc(spec)
    Counter.dinc(spec, 3.5)

    ## dinc is async. let's make sure gen_server processed our request
    Process.sleep(10)
    assert 4.5 == Counter.value(spec)

    Counter.reset(spec)

    assert 0 == Counter.value(spec)
  end

  test "remove" do
    spec = [name: :http_requests_total,
            labels: [:method],
            help: ""]
    wl_spec = [name: :simple_counter,
               help: ""]

    Counter.new(spec)
    Counter.new(wl_spec)

    Counter.inc(spec)
    Counter.inc(wl_spec)

    assert 1 == Counter.value(spec)
    assert 1 == Counter.value(wl_spec)

    assert true == Counter.remove(spec)
    assert true == Counter.remove(wl_spec)

    assert :undefined == Counter.value(spec)
    assert :undefined == Counter.value(wl_spec)

    assert false == Counter.remove(spec)
    assert false == Counter.remove(wl_spec)
  end

  test "default value" do
    lspec = [name: :http_requests_total,
             labels: [:method],
             help: ""]
    Counter.new(lspec)

    assert :undefined == Counter.value(lspec)

    spec = [name: :something_total,
            labels: [],
            help: ""]
    Counter.new(spec)

    assert 0 == Counter.value(spec)
  end

  defmodule CounterInjectorsTest do

    use Prometheus.Metric

    @counter name: :calls_total, help: ""
    @counter name: :sometimes_total, help: ""
    @counter name: :exceptions_total, help: ""
    @counter name: :no_exceptions_total, help: ""

    Counter.count name: :calls_total do
      def decorated_fun() do
        IO.puts("I'm decorated fun")
      end

      def decorated_fun1() do
        IO.puts("I'm decorated fun1")
        IO.puts("I'm decorated fun1")
      end
    end

    def sometimes_count(arg) do
      if arg do
        Counter.count [name: :sometimes_total], do: IO.puts "Called indeed!"
      else
        IO.puts("Not this time")
      end
    end

    Counter.count_no_exceptions [name: :no_exceptions_total] do
      Counter.count_exceptions [name: :exceptions_total], ArithmeticError do
        def sometimes_raise(arg) do
          5 / arg
        end
      end

      def sometimes_raise1(arg) when is_list(arg) do
        5 / arg
      end
    end

    def qwe () do
      Counter.count_no_exceptions [name: :no_exceptions_total], fn () ->
        IO.puts 1
        IO.puts 2
      end
    end

    Counter.count_exceptions [name: :exceptions_total] do
      def sometimes_raise_any(arg) do
        5 / arg
      end
    end
  end

  test "decorators test" do

    CounterInjectorsTest.__declare_prometheus_metrics__()

    assert 0 == Counter.value name: :calls_total
    assert capture_io(fn -> CounterInjectorsTest.decorated_fun() end) ==
      "I'm decorated fun\n"
    assert 1 == Counter.value name: :calls_total
    assert capture_io(fn -> CounterInjectorsTest.decorated_fun1() end) ==
      "I'm decorated fun1\nI'm decorated fun1\n"
    assert 2 == Counter.value name: :calls_total

    assert 0 == Counter.value name: :sometimes_total
    assert capture_io(fn -> CounterInjectorsTest.sometimes_count(true) end) ==
      "Called indeed!\n"
    assert capture_io(fn -> CounterInjectorsTest.sometimes_count(false) end) ==
      "Not this time\n"
    assert 1 == Counter.value name: :sometimes_total

    assert 0 == Counter.value name: :exceptions_total
    assert 0 == Counter.value name: :no_exceptions_total
    assert 1 == CounterInjectorsTest.sometimes_raise(5)
    assert 0 == Counter.value name: :exceptions_total
    assert 1 == Counter.value name: :no_exceptions_total
    assert_raise ArithmeticError,
    fn ->
      CounterInjectorsTest.sometimes_raise(0)
    end
    assert 1 == Counter.value name: :exceptions_total
    assert 1 == Counter.value name: :no_exceptions_total

    assert 1 == Counter.value name: :exceptions_total
    assert 1 == CounterInjectorsTest.sometimes_raise(5)
    assert 1 == Counter.value name: :exceptions_total
    assert_raise ArithmeticError,
    fn ->
      CounterInjectorsTest.sometimes_raise(0)
    end
    assert 2 == Counter.value name: :exceptions_total

  end

end
