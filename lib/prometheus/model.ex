defmodule Prometheus.Model do
  @moduledoc """
  Helpers for working with Prometheus data model. For advanced users.
  Probably will be used with `Prometheus.Collector`.
  """

  use Prometheus.Erlang, :prometheus_model_helpers

  @doc """
  Create Metric Family of `type`, `name` and `help`.
  `collector.collect_metrics/2` callback will be called and expected to
  return individual metrics list.
  """
  defmacro create_mf(name, help, type, collector, collector_data) do
    Erlang.call([name, help, type, collector, collector_data])
  end

  @doc """
  Creates gauge metrics from `mdata` {label, value} tuple list.

      iex(11)> Prometheus.Model.gauge_metrics([{[host: "example.com"], 100}])
      [{:Metric, [{:LabelPair, "host", "example.com"}], {:Gauge, 100}, :undefined,
      :undefined, :undefined, :undefined, :undefined}]

  """
  defmacro gauge_metrics(mdata) do
    Erlang.call([mdata])
  end

  @doc """
  Creates gauge metric with `value` and `labels`

      iex(13)> Prometheus.Model.gauge_metric(100, [host: "example.com"])
      {:Metric, [{:LabelPair, "host", "example.com"}], {:Gauge, 100}, :undefined,
       :undefined, :undefined, :undefined, :undefined}

  """
  defmacro gauge_metric(value, labels \\ []) do
    Erlang.call([labels, value])
  end

  @doc """
  Creates counter metrics from `mdata` {labels, value} tuple list.

      iex(14)> Prometheus.Model.counter_metrics([{[host: "example.com"], 100}])
      [{:Metric, [{:LabelPair, "host", "example.com"}], :undefined, {:Counter, 100},
      :undefined, :undefined, :undefined, :undefined}]

  """
  defmacro counter_metrics(mdata) do
    Erlang.call([mdata])
  end

  @doc """
  Creates counter metric with `value` and `labels`.

      iex(15)> Prometheus.Model.counter_metric(100, [host: "example.com"])
      {:Metric, [{:LabelPair, "host", "example.com"}], :undefined, {:Counter, 100},
      :undefined, :undefined, :undefined, :undefined}

  """
  defmacro counter_metric(value, labels \\ []) do
    Erlang.call([labels, value])
  end

  @doc """
  Creates summary metrics from `mdata` {labels, count, sum} tuple list.
  """
  defmacro summary_metrics(mdata) do
    Erlang.call([mdata])
  end

  @doc """
  Creates summary metric with `count`, `sum` and `labels`.
  """
  defmacro summary_metric(count, sum, labels \\ []) do
    Erlang.call([labels, count, sum])
  end

  @doc """
  Creates histogram metrics from `mdata` {labels, buckets, count, sum} tuple list.
  """
  defmacro histogram_metrics(mdata) do
    Erlang.call([mdata])
  end

  @doc """
  Creates histogram metric with `buckets`, `count`, `sum`, and `labels`.
  """
  defmacro histogram_metric(buckets, count, sum, labels \\ []) do
    Erlang.call([labels, buckets, count, sum])
  end

end
