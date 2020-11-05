defmodule Prometheus.InvalidValueError do
  @moduledoc """
  Raised when given `value` is invalid i.e. when you pass a negative number to
  `Prometheus.Metric.Counter.inc/2`.
  """
  defexception [:value, :orig_message]

  def message(%{value: value, orig_message: message}) do
    "Invalid value: #{inspect(value)} (#{message})."
  end
end

defmodule Prometheus.InvalidMetricNameError do
  @moduledoc """
  Raised when given metric `name` is invalid i.e. can't be represented as printable utf-8
  string that matches `^[a-zA-Z_:][a-zA-Z0-9_:]*$` regular expression.
  """
  defexception [:name]

  def message(%{name: name}) do
    "Invalid metric name: #{name}."
  end
end

defmodule Prometheus.InvalidMetricLabelsError do
  @moduledoc """
  Raised when `labels` isn't a list.
  """
  defexception [:labels]

  def message(%{labels: labels}) do
    "Invalid metric labels: #{labels}."
  end
end

defmodule Prometheus.InvalidMetricHelpError do
  @moduledoc """
  Raised when given metric `help` is invalid i.e. isn't a printable utf-8 string.
  """
  defexception [:help]

  def message(%{help: help}) do
    "Invalid metric help: #{help}."
  end
end

defmodule Prometheus.InvalidMetricArityError do
  @moduledoc """
  Raised when metric arity is invalid e.g. counter metric was created with two labels but
  only one label value is passed to `Prometheus.Metric.Counter.inc/2`.
  """
  defexception [:present, :expected]

  def message(%{present: present, expected: expected}) do
    "Invalid metric arity: got #{present}, expected #{expected}."
  end
end

defmodule Prometheus.UnknownMetricError do
  defexception [:registry, :name]

  def message(%{registry: registry, name: name}) do
    "Unknown metric {registry: #{registry}, name: #{name}}."
  end
end

defmodule Prometheus.InvalidLabelNameError do
  @moduledoc """
  Raised when label `name` is invalid i.e. can't be represented as printable utf-8 string
  that matches `^[a-zA-Z_][a-zA-Z0-9_]*$` regular expression or starts with `__`.

  Metric can impose further restrictions on label names.
  """
  defexception [:name, :orig_message]

  def message(%{name: name, orig_message: message}) do
    "Invalid label name: #{name} (#{message})."
  end
end

defmodule Prometheus.MFAlreadyExistsError do
  @moduledoc """
  Raised when one tries to create metric in `registry` with `name` it already exists.
  """
  defexception [:registry, :name]

  def message(%{registry: registry, name: name}) do
    "Metric #{registry}:#{name} already exists."
  end
end

defmodule Prometheus.NoBucketsError do
  @moduledoc """
  Raised by histogram constructors when buckets can't be found in spec, or
  found value is empty list.
  """
  defexception [:buckets]

  def message(%{buckets: buckets}) do
    "Invalid histogram buckets: #{buckets}."
  end
end

defmodule Prometheus.InvalidBucketsError do
  @moduledoc """
  Raised by histogram constructors when buckets are invalid i.e. not sorted in increasing
  order or generator spec is unknown.
  """
  defexception [:buckets, :orig_message]

  def message(%{buckets: buckets, orig_message: message}) do
    buckets = :io_lib.format("~p", [buckets])
    "Invalid histogram buckets: #{buckets} (#{message})."
  end
end

defmodule Prometheus.InvalidBoundError do
  @moduledoc """
  Raised by histogram constructors when bucket bound isn't a number.
  """
  defexception [:bound]

  def message(%{bound: bound}) do
    "Invalid histogram bound: #{bound}."
  end
end

defmodule Prometheus.MissingMetricSpecKeyError do
  @moduledoc """
  Raised when required metric `spec` `key` is missing. All metrics
  require at least `name` and when metric created `help`.

  Metrics can have their specific required keys.
  """
  defexception [:key, :spec]

  def message(%{key: key}) do
    "Required key #{key} is missing from metric spec."
  end
end

defmodule Prometheus.InvalidBlockArityError do
  @moduledoc """
  Raised when fn passed as block has more then 0 arguments
  """
  defexception [:args]

  def message(%{args: args}) do
    insp = Enum.map_join(args, ", ", &inspect/1)
    "Fn with arity #{length(args)} (args: #{insp}) passed as block."
  end
end

defmodule Prometheus.Error do
  @moduledoc false

  # credo:disable-for-this-file Credo.Check.Refactor.ABCSize
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  def normalize(erlang_error) do
    case erlang_error do
      %ErlangError{original: original} ->
        case original do
          {:invalid_value, value, message} ->
            %Prometheus.InvalidValueError{value: value, orig_message: message}

          {:invalid_metric_name, name, _message} ->
            %Prometheus.InvalidMetricNameError{name: name}

          {:invalid_metric_help, help, _message} ->
            %Prometheus.InvalidMetricHelpError{help: help}

          {:invalid_metric_arity, present, expected} ->
            %Prometheus.InvalidMetricArityError{present: present, expected: expected}

          {:unknown_metric, registry, name} ->
            %Prometheus.UnknownMetricError{registry: registry, name: name}

          {:invalid_metric_labels, labels, _message} ->
            %Prometheus.InvalidMetricLabelsError{labels: labels}

          {:invalid_metric_label_name, name, message} ->
            %Prometheus.InvalidLabelNameError{name: name, orig_message: message}

          {:mf_already_exists, {registry, name}, _message} ->
            %Prometheus.MFAlreadyExistsError{registry: registry, name: name}

          {:no_buckets, buckets} ->
            %Prometheus.NoBucketsError{buckets: buckets}

          {:invalid_buckets, buckets, message} ->
            %Prometheus.InvalidBucketsError{
              buckets: buckets,
              orig_message: message
            }

          {:invalid_bound, bound} ->
            %Prometheus.InvalidBoundError{bound: bound}

          {:missing_metric_spec_key, key, spec} ->
            %Prometheus.MissingMetricSpecKeyError{key: key, spec: spec}

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
        e in ErlangError ->
          reraise(
            Prometheus.Error.normalize(e),
            unquote(quote(do: __STACKTRACE__))
          )
      end
    end
  end
end
