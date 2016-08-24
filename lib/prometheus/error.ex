defmodule Prometheus.Error do

  defmodule InvalidValue do
    defexception [:value, :message]
  end

  defmodule InvalidMetricName do
    defexception [:name, :message]
  end

  defmodule InvalidMetricHelp do
    defexception [:help, :message]
  end

  defmodule InvalidMetricArity do
    defexception [:arity]

    def message(%{arity: arity}) do
      "invalid metric arity: #{arity}"
    end
  end

  defmodule UnknownMetric do
    defexception [:registry, :name]


    def message(%{registry: registry, name: name}) do
      "unknown metric {registry: #{registry}, name: #{name}}"
    end
  end

  defmodule InvalidMetricLabels do
    defexception [:labels, :message]
  end

  defmodule InvalidLabelName do
    defexception [:name, :message]
  end

  defmodule MFAlreadyExists do
    defexception [:registry, :name, :message]
  end

  defmodule HistogramNoBuckets do
    defexception [:buckets, :message]
  end

  defmodule HistogramInvalidBuckets do
    defexception [:buckets, :message]
  end

  defmodule HistogramInvalidBound do
    defexception [:bound, :message]
  end

  defmodule MissingMetricSpecKey do
    defexception [:key, :spec, :message]
  end

  def normalize(erlang_error) do
    case erlang_error do
      %ErlangError{original: original} ->
        case original do
          {:invalid_value, value, message} ->
            %InvalidValue{value: value, message: message}
          {:invalid_metric_name, name, message} ->
            %InvalidMetricName{name: name, message: message}
          {:invalid_metric_help, help, message} ->
            %InvalidMetricHelp{help: help, message: message}
          {:invalid_metric_arity, arity} ->
            %InvalidMetricArity{arity: arity}
          {:unknown_metric, registry, name} ->
            %UnknownMetric{registry: registry, name: name}
          {:invalid_metric_labels, labels, message} ->
            %InvalidMetricLabels{labels: labels, message: message}
          {:invalid_metric_label_name, name, message} ->
            %InvalidLabelName{name: name, message: message}
          {:mf_already_exists, {registry, name}, message} ->
            %MFAlreadyExists{registry: registry, name: name, message: message}
          {:histogram_no_buckets, buckets} ->
            %HistogramNoBuckets{buckets: buckets}
          {:histogram_invalid_buckets, buckets} ->
            %HistogramInvalidBuckets{buckets: buckets, message: "buckets are invalid"}
          {:histogram_invalid_buckets, buckets, message} ->
            %HistogramInvalidBuckets{buckets: buckets, message: message}
          {:histogram_invalid_bound, bound} ->
            %HistogramInvalidBound{bound: bound, message: "bound is invalid"}
          {:missing_metric_spec_key, key, spec} ->
            %MissingMetricSpecKey{key: key, spec: spec}
          _ ->
            erlang_error
        end
      _ ->
        erlang_error
    end
  end

  defmacro with_prometheus_error(block) do
    quote do
      try do
        unquote(block)
      rescue
        e in ErlangError -> reraise Prometheus.Error.normalize(e), System.stacktrace
      end
    end
  end
end
