defmodule Prometheus.ModelTest do

  use Prometheus.Case

  require Prometheus.Model

  doctest Prometheus.Model

  def collect_metrics(:pool_size, _) do
    Prometheus.Model.untyped_metric(365)
  end

  test "create_mf" do
    assert {:MetricFamily,<<"pool_size">>,<<"help">>,:UNTYPED,
            [{:Metric,[],:undefined,:undefined,:undefined,
              {:Untyped,365},
              :undefined,:undefined}]} ==
      Prometheus.Model.create_mf(:pool_size, "help", :untyped, Prometheus.ModelTest, :undefined)
  end
end
