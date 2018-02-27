defmodule Prometheus.MetricTest do
  use Prometheus.Case

  doctest Prometheus.Metric

  defmacro __before_compile__(_env) do
    quote do
      def injected_fun() do
        1
      end
    end
  end

  test "@metric attributes leads to metric declaration" do
    defmodule ModuleWithMetrics do
      use Prometheus.Metric
      @before_compile Prometheus.MetricTest

      @counter name: :test_counter1, labels: [], help: "qwe"
      @counter name: :test_counter2, labels: [:tag], help: "qwa"

      @gauge name: :test_gauge1, labels: [], help: "qwe"
      @gauge name: :test_gauge2, labels: [:tag], help: "qwa"

      @boolean name: :test_boolean1, labels: [], help: "qwe"
      @boolean name: :test_boolean2, labels: [:tag], help: "qwa"

      @summary name: :test_summary1, labels: [], help: "qwe"
      @summary name: :test_summary2, labels: [:tag], help: "qwa"

      @histogram name: :test_histogram1, labels: [], buckets: [1, 2], help: "qwe"
      @histogram name: :test_histogram2, labels: [:tag], buckets: [1, 2], help: "qwa"

      @on_load :custom_on_load_fun

      def custom_on_load_fun() do
        Counter.declare(name: :custom_counter, labels: [], help: "qwe")
        :ok
      end
    end

    defmodule ModuleWithoutOnLoad do
      use Prometheus.Metric

      @counter name: :test_counter3, labels: [], help: "qwe"
    end

    assert 1 == ModuleWithMetrics.injected_fun()

    assert false == Counter.declare(name: :custom_counter, labels: [], help: "qwe")
    assert false == Counter.declare(name: :test_counter3, labels: [], help: "qwe")

    assert false == Counter.declare(name: :test_counter1, labels: [], help: "qwe")
    assert false == Counter.declare(name: :test_counter2, labels: [:tag], help: "qwa")

    assert false == Gauge.declare(name: :test_gauge1, labels: [], help: "qwe")
    assert false == Gauge.declare(name: :test_gauge2, labels: [:tag], help: "qwa")

    assert false == Boolean.declare(name: :test_boolean1, labels: [], help: "qwe")
    assert false == Boolean.declare(name: :test_boolean2, labels: [:tag], help: "qwa")

    assert false == Summary.declare(name: :test_summary1, labels: [], help: "qwe")
    assert false == Summary.declare(name: :test_summary2, labels: [:tag], help: "qwa")

    assert false ==
             Histogram.declare(
               name: :test_histogram1,
               labels: [],
               buckets: [1, 2],
               help: ""
             )

    assert false ==
             Histogram.declare(
               name: :test_histogram2,
               labels: [:tag],
               buckets: [1, 2],
               help: ""
             )
  end
end
