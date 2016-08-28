defmodule Prometheus.Error do
  @moduledoc false

  defmodule InvalidValue do
    @moduledoc """
    Raised when given `value` is invalid i.e. when you pass a negative number to `Prometheus.Metric.Counter.inc/2`.
    """
    defexception [:value, :message]
  end

  defmodule InvalidMetricName do
    @moduledoc """
    Raised when given metric `name` is invalid i.e. can't be represented as printable utf-8 string that matches
    `^[a-zA-Z_:][a-zA-Z0-9_:]*$` regular expression.
    """
    defexception [:name, :message]
  end

  defmodule InvalidMetricHelp do
    @moduledoc """
    Raised when given metric `help` is invalid i.e. isn't a printable utf-8 string.
    """
    defexception [:help, :message]
  end

  defmodule InvalidMetricArity do
    @moduledoc """
    Raised when metric arity is invalid e.g. counter metric was created with two labels but
    only one label value is passed to `Prometheus.Metric.Counter.inc/2`.
    """
    defexception [:present, :expected]

    def message(%{present: present, expected: expected}) do
      "invalid metric arity: got #{present}, expected #{expected}."
    end
  end

  defmodule UnknownMetric do
    defexception [:registry, :name]


    def message(%{registry: registry, name: name}) do
      "unknown metric {registry: #{registry}, name: #{name}}"
    end
  end

  defmodule InvalidMetricLabels do
    @moduledoc """
    Raised when `labels` isn't a list.
    """
    defexception [:labels, :message]
  end

  defmodule InvalidLabelName do
    @moduledoc """
    Raised when label `name` is invalid i.e. can't be represented as printable utf-8 string that matches
    `^[a-zA-Z_][a-zA-Z0-9_]*$` regular expression or starts with `__`.

    Metric can impose further restrictions on label names.
    """
    defexception [:name, :message]
  end

  defmodule MFAlreadyExists do
    @moduledoc """
    Raised when one tries to create metric in `registry` with `name` it already exists.
    """
    defexception [:registry, :name, :message]
  end

  defmodule HistogramNoBuckets do
    @moduledoc """
    Raised by histogram constructors when buckets can't be found in spec, or
    found value is empty list.
    """
    defexception [:buckets, :message]
  end

  defmodule HistogramInvalidBuckets do
    @moduledoc """
    Raised by histogram constructors when buckets are invalid i.e. not sorted in increasing
    order or generator spec is unknown.
    """
    defexception [:buckets, :message]
  end

  defmodule HistogramInvalidBound do
    @moduledoc """
    Raised by histogram constructors when bucket bound isn't a number.
    """
    defexception [:bound, :message]
  end

  defmodule MissingMetricSpecKey do
    @moduledoc """
    Raised when required metric `spec` `key` is missing. All metrics
    require at least `name` and when metric created `help`.

    Metrics can have their specific required keys.
    """
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
          {:invalid_metric_arity, present, expected} ->
            %InvalidMetricArity{present: present, expected: expected}
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
