defmodule Prometheus.RegistryTest do

  use Prometheus.Case
  alias Prometheus.Registry
  alias Prometheus.RegistryTest

  import ExUnit.CaptureIO

  def deregister_cleanup(_), do: :ok

  test "registry exists" do
    Prometheus.Registry.register_collector(:test_registry, RegistryTest)

    assert true == Registry.exists(:test_registry)

    assert :test_registry == Registry.exists("test_registry")

    assert false == Registry.exists(:qweqwe)
    assert false == Registry.exists("qweqwe")
  end

  test "default Registry" do
    # default registry
    assert :ok == Prometheus.Registry.register_collector(RegistryTest)
    assert [RegistryTest] == Registry.collectors()
    assert true == Registry.collector_registered?(RegistryTest)
    Registry.clear()
    assert [] == Registry.collectors()
    assert false == Registry.collector_registered?(RegistryTest)

    assert :ok == Registry.register_collector(RegistryTest)
    Registry.deregister_collector(RegistryTest)
    assert [] == Registry.collectors()
    assert false == Registry.collector_registered?(RegistryTest)

    ## custom registry
    assert :ok == Registry.register_collector(:custom_collector, RegistryTest)
    assert [RegistryTest] == Registry.collectors(:custom_collector)
    assert true == Registry.collector_registered?(:custom_collector, RegistryTest)
    Registry.clear(:custom_collector)
    assert [] == Registry.collectors(:custom_collector)
    assert false == Registry.collector_registered?(:custom_collector, RegistryTest)

    assert :ok == Registry.register_collector(:custom_collector, RegistryTest)
    Registry.deregister_collector(:custom_collector, RegistryTest)
    assert [] == Registry.collectors(:custom_collector)
    assert false == Registry.collector_registered?(:custom_collector, RegistryTest)

    ## register_collectors && collect; default registry
    assert :ok == Registry.register_collectors([RegistryTest])
    assert [RegistryTest] == Registry.collectors()
    assert capture_io(fn ->
      Registry.collect(fn (:default, collector) ->
        :io.format("~p", [collector])
      end) ==
        "Elixir.RegistryTest"
    end)

    ## register_collectors && collect; custom registry
    assert :ok == Registry.register_collectors(:custom_collector, [RegistryTest])
    assert [RegistryTest] == Registry.collectors(:custom_collector)
    assert capture_io(fn ->
      Registry.collect(fn (:custom_collector, collector) ->
        :io.format("~p", [collector])
      end, :custom_collector) ==
        "Elixir.RegistryTest"
    end)
  end
end
