defmodule Prometheus.Model do
  @moduledoc """
  Helpers for working with Prometheus data model. For advanced users.

  `Prometheus.Collector` example demonstrates how to use this module.
  """

  use Prometheus.Erlang, :prometheus_model_helpers

  @doc """
  Creates Metric Family of `type`, `name` and `help`.
  `collector.collect_metrics/2` callback will be called and expected to
  return individual metrics list.
  """
  delegate create_mf(name, help, type, collector, collector_data)

  @doc """
  Creates gauge metrics from `mdata` {label, value} tuple list.

      iex(11)> Prometheus.Model.gauge_metrics([{[host: "example.com"], 100}])
      [{:Metric, [{:LabelPair, "host", "example.com"}], {:Gauge, 100}, :undefined,
      :undefined, :undefined, :undefined, :undefined}]

  """
  delegate gauge_metrics(mdata)

  @doc """
  Creates gauge metric with `labels` and `value`.

      iex(13)> Prometheus.Model.gauge_metric([host: "example.com"], 100)
      {:Metric, [{:LabelPair, "host", "example.com"}], {:Gauge, 100}, :undefined,
       :undefined, :undefined, :undefined, :undefined}

  """
  delegate gauge_metric(labels \\ [], value)

  @doc """
  Creates untyped metrics from `mdata` {label, value} tuple list.

      iex(11)> Prometheus.Model.untyped_metrics([{[host: "example.com"], 100}])
      [{:Metric, [{:LabelPair, "host", "example.com"}], :undefined,
      :undefined, :undefined, {:Untyped, 100}, :undefined, :undefined}]

  """
  delegate untyped_metrics(mdata)

  @doc """
  Creates untyped metric with `labels` and `value`.

      iex(13)> Prometheus.Model.untyped_metric([host: "example.com"], 100)
      {:Metric, [{:LabelPair, "host", "example.com"}], :undefined,
       :undefined, :undefined, {:Untyped, 100}, :undefined, :undefined}

  """
  delegate untyped_metric(labels \\ [], value)

  @doc """
  Creates counter metrics from `mdata` {labels, value} tuple list.

      iex(14)> Prometheus.Model.counter_metrics([{[host: "example.com"], 100}])
      [{:Metric, [{:LabelPair, "host", "example.com"}], :undefined, {:Counter, 100},
      :undefined, :undefined, :undefined, :undefined}]

  """
  delegate counter_metrics(mdata)

  @doc """
  Creates counter metric with `labels` and `value`.

      iex(15)> Prometheus.Model.counter_metric([host: "example.com"], 100)
      {:Metric, [{:LabelPair, "host", "example.com"}], :undefined, {:Counter, 100},
      :undefined, :undefined, :undefined, :undefined}

  """
  delegate counter_metric(labels \\ [], value)

  @doc """
  Creates summary metrics from `mdata` {labels, count, sum} tuple list.

      iex(7)> Prometheus.Model.summary_metrics([{[{:method, :get}], 2, 10.5}])
      [{:Metric, [{:LabelPair, "method", "get"}], :undefined, :undefined,
        {:Summary, 2, 10.5, []}, :undefined, :undefined, :undefined}]

  """
  delegate summary_metrics(mdata)

  @doc """
  Creates summary metric with `labels`, `count`, and `sum`.

      iex(3)> Prometheus.Model.summary_metric([{:method, :get}], 2, 10.5)
      {:Metric, [{:LabelPair, "method", "get"}], :undefined, :undefined,
        {:Summary, 2, 10.5, []}, :undefined, :undefined, :undefined}

  """
  delegate summary_metric(labels \\ [], count, sum)

  @doc """
  Creates histogram metrics from `mdata` {labels, buckets, count, sum} tuple list.

      iex(2)> Prometheus.Model.histogram_metrics([{[{:method, :get}],
      ...(2)>                                      [{2, 1}, {5, 1}, {:infinity, 2}],
      ...(2)>                                      2, 10.5}])
      [{:Metric, [{:LabelPair, "method", "get"}], :undefined, :undefined, :undefined,
        :undefined,
        {:Histogram, 2, 10.5,
         [{:Bucket, 1, 2}, {:Bucket, 1, 5}, {:Bucket, 2, :infinity}]}, :undefined}]

  """
  delegate histogram_metrics(mdata)

  @doc """
  Creates histogram metric with `labels`, `buckets`, `count`, and `sum`.

      iex(4)> Prometheus.Model.histogram_metric([{:method, :get}],
      ...(4)>                                    [{2, 1}, {5, 1}, {:infinity, 2}],
      ...(4)>                                    2, 10.5)
      {:Metric, [{:LabelPair, "method", "get"}], :undefined, :undefined, :undefined,
      :undefined,
      {:Histogram, 2, 10.5,
      [{:Bucket, 1, 2}, {:Bucket, 1, 5}, {:Bucket, 2, :infinity}]}, :undefined}

  Buckets is a list of pairs {upper_bound, cumulative_count}.
  Cumulative count is a sum of all cumulative_counts of previous buckets + counter of
  current bucket.

  """
  delegate histogram_metric(labels \\ [], buckets, count, sum)
end
