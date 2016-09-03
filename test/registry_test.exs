defmodule Prometheus.RegistryTest do

  use Prometheus.Case

  import ExUnit.CaptureIO

  def deregister_cleanup(_), do: :ok

  test "default Registry" do
    # default registry
    assert :ok == Prometheus.Registry.register_collector(Prometheus.RegistryTest)
    assert [Prometheus.RegistryTest] == Prometheus.Registry.collectors()
    assert true == Prometheus.Registry.collector_registered?(Prometheus.RegistryTest)
    Prometheus.Registry.clear()
    assert [] == Prometheus.Registry.collectors()
    assert false == Prometheus.Registry.collector_registered?(Prometheus.RegistryTest)

    assert :ok == Prometheus.Registry.register_collector(Prometheus.RegistryTest)
    Prometheus.Registry.deregister_collector(Prometheus.RegistryTest)
    assert [] == Prometheus.Registry.collectors()
    assert false == Prometheus.Registry.collector_registered?(Prometheus.RegistryTest)

    ## custom registry
    assert :ok == Prometheus.Registry.register_collector(:custom_collector, Prometheus.RegistryTest)
    assert [Prometheus.RegistryTest] == Prometheus.Registry.collectors(:custom_collector)
    assert true == Prometheus.Registry.collector_registered?(:custom_collector, Prometheus.RegistryTest)
    Prometheus.Registry.clear(:custom_collector)
    assert [] == Prometheus.Registry.collectors(:custom_collector)
    assert false == Prometheus.Registry.collector_registered?(:custom_collector, Prometheus.RegistryTest)

    assert :ok == Prometheus.Registry.register_collector(:custom_collector, Prometheus.RegistryTest)
    Prometheus.Registry.deregister_collector(:custom_collector, Prometheus.RegistryTest)
    assert [] == Prometheus.Registry.collectors(:custom_collector)
    assert false == Prometheus.Registry.collector_registered?(:custom_collector, Prometheus.RegistryTest)

    ## register_collectors && collect; default registry
    assert :ok == Prometheus.Registry.register_collectors([Prometheus.RegistryTest])
    assert [Prometheus.RegistryTest] == Prometheus.Registry.collectors()
    assert capture_io(fn ->
      Prometheus.Registry.collect(fn (:default, collector) ->
        :io.format("~p", [collector])
      end) ==
        "Elixir.Prometheus.RegistryTest"
    end)

    ## register_collectors && collect; custom registry
    assert :ok == Prometheus.Registry.register_collectors(:custom_collector, [Prometheus.RegistryTest])
    assert [Prometheus.RegistryTest] == Prometheus.Registry.collectors(:custom_collector)
    assert capture_io(fn ->
      Prometheus.Registry.collect(fn (:custom_collector, collector) ->
        :io.format("~p", [collector])
      end, :custom_collector) ==
        "Elixir.Prometheus.RegistryTest"
    end)
  end
end
