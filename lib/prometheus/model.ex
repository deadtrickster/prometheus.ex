defmodule Prometheus.Model do
  @moduledoc """
  Helpers for working with Prometheus data model. For advanced users.
  Probably will be used with `Prometheus.Collector`.
  """

  require Prometheus.Error

  @doc """
  Create Metric Family of `type`, `name` and `help`.
  `collector.collect_metrics/2` callback will be called and expected to
  return individual metrics list.
  """
  defmacro create_mf(name, help, type, collector, collector_data) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.create_mf(unquote(name), unquote(help), unquote(type), unquote(collector), unquote(collector_data))
      )
    end
  end

  @doc """
  Creates gauge metrics from `mdata` {label, value} tuple list.

      iex(11)> Prometheus.Model.gauge_metrics([{[host: "example.com"], 100}])
      [{:Metric, [{:LabelPair, "host", "example.com"}], {:Gauge, 100}, :undefined,
      :undefined, :undefined, :undefined, :undefined}]

  """
  defmacro gauge_metrics(mdata) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.gauge_metrics(unquote(mdata))
      )
    end
  end

  @doc """
  Creates gauge metric with `value` and `labels`

      iex(13)> Prometheus.Model.gauge_metric(100, [host: "example.com"])
      {:Metric, [{:LabelPair, "host", "example.com"}], {:Gauge, 100}, :undefined,
       :undefined, :undefined, :undefined, :undefined}

  """
  defmacro gauge_metric(value, labels \\ []) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.gauge_metric(unquote(labels), unquote(value))
      )
    end
  end

  @doc """
  Creates counter metrics from `mdata` {labels, value} tuple list.

      iex(14)> Prometheus.Model.counter_metrics([{[host: "example.com"], 100}])
      [{:Metric, [{:LabelPair, "host", "example.com"}], :undefined, {:Counter, 100},
      :undefined, :undefined, :undefined, :undefined}]

  """
  defmacro counter_metrics(mdata) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.counter_metrics(unquote(mdata))
      )
    end
  end

  @doc """
  Creates counter metric with `value` and `labels`.

      iex(15)> Prometheus.Model.counter_metric(100, [host: "example.com"])
      {:Metric, [{:LabelPair, "host", "example.com"}], :undefined, {:Counter, 100},
      :undefined, :undefined, :undefined, :undefined}

  """
  defmacro counter_metric(value, labels \\ []) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.counter_metric(unquote(labels), unquote(value))
      )
    end
  end

  @doc """
  Creates summary metrics from `mdata` {labels, count, sum} tuple list.
  """
  defmacro summary_metrics(mdata) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.summary_metrics(unquote(mdata))
      )
    end
  end

  @doc """
  Creates summary metric with `count`, `sum` and `labels`.
  """
  defmacro summary_metric(count, sum, labels \\ []) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.summary_metric(unquote(labels), unquote(count), unquote(sum))
      )
    end
  end

  @doc """
  Creates histogram metrics from `mdata` {labels, buckets, count, sum} tuple list.
  """
  defmacro histogram_metrics(mdata) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.histogram_metrics(unquote(mdata))
      )
    end
  end

  @doc """
  Creates histogram metric with `buckets`, `count`, `sum`, and `labels`.
  """
  defmacro histogram_metric(buckets, count, sum, labels \\ []) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.histogram_metric(unquote(labels), unquote(buckets), unquote(count), unquote(sum))
      )
    end
  end

  defmacro label_pairs(labels) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.label_pairs(unquote(labels))
      )
    end
  end

  defmacro label_pair(name, value) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.label_pair({unquote(name), unquote(value)})
      )
    end
  end

end
