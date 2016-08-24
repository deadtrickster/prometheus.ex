defmodule Prometheus.Model do

  require Prometheus.Error

  defmacro create_mf(name, help, type, collector, collector_data) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.create_mf(unquote(name), unquote(help), unquote(type), unquote(collector), unquote(collector_data))
      )
    end
  end

  defmacro gauge_metrics(mdata) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.gauge_metrics(unquote(mdata))
      )
    end
  end

  defmacro gauge_metric(value, labels \\ []) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.gauge_metric(unquote(labels), unquote(value))
      )
    end
  end

  defmacro counter_metrics(mdata) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.counter_metrics(unquote(mdata))
      )
    end
  end

  defmacro counter_metric(value, labels \\ []) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.counter_metric(unquote(labels), unquote(value))
      )
    end
  end

  defmacro summary_metrics(mdata) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.summary_metrics(unquote(mdata))
      )
    end
  end

  defmacro summary_metric(count, sum, labels \\ []) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.summary_metric(unquote(labels), unquote(count), unquote(sum))
      )
    end
  end

  defmacro histogram_metrics(mdata) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_model_helpers.histogram_metrics(unquote(mdata))
      )
    end
  end

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
