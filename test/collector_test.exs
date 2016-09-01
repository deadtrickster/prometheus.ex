defmodule Prometheus.CollectorTest do

  use Prometheus.Case

  import ExUnit.CaptureIO

  def deregister_cleanup(_), do: :ok

  test "Collector tests" do
    # ## test registration in default registry
    # Prometheus.Collector.register(Prometheus.CollectorTest)
    # assert true == Prometheus.Registry.collector_registered?(Prometheus.CollectorTest)

    # ## test registration in custom registry
    # Prometheus.Collector.register(Prometheus.CollectorTest, :qwe)
    # assert true == Prometheus.Registry.collector_registered?(Prometheus.CollectorTest, :qwe)

    # ## test deregistration in default registry
    # Prometheus.Collector.deregister(Prometheus.CollectorTest)
    # assert false == Prometheus.Registry.collector_registered?(Prometheus.CollectorTest)

    # ## test deregistration in custom registry
    # Prometheus.Collector.deregister(Prometheus.CollectorTest, :qwe)
    # assert false == Prometheus.Registry.collector_registered?(Prometheus.CollectorTest, :qwe)

    ## test collecting metrics from collector in default registry
    Counter.declare([name: :test_counter,
                     help: "qwe_qwe"])

    Counter.inc([name: :test_counter])

    assert capture_io(fn ->
      Prometheus.Collector.collect_mf(:prometheus_counter, fn(mf) ->
        :io.format("~p", [mf])
      end)
    end) ==
"{'MetricFamily',<<\"test_counter\">>,\"qwe_qwe\",'COUNTER',
                [{'Metric',[],undefined,
                           {'Counter',1},
                           undefined,undefined,undefined,undefined}]}"

    ## test collecting metrics from collector in custom registry
    Counter.declare([name: :test_counter_qwe,
                     help: "qwe_qwe",
                     registry: :qwe])

    Counter.inc([name: :test_counter_qwe,
                 registry: :qwe])

    assert capture_io(fn ->
      Prometheus.Collector.collect_mf(:prometheus_counter, fn(mf) ->
        :io.format("~p", [mf])
      end, :qwe)
    end) ==
"{'MetricFamily',<<\"test_counter_qwe\">>,\"qwe_qwe\",'COUNTER',
                [{'Metric',[],undefined,
                           {'Counter',1},
                           undefined,undefined,undefined,undefined}]}"
  end
end
