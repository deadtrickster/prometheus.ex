defmodule Prometheus.Metric.Counter do
  @moduledoc """
  Counter is a Metric that represents a single numerical value that only ever
  goes up. That implies that it cannot be used to count items whose number can
  also go down, e.g. the number of currently running processes. Those
  "counters" are represented by `Prometheus.Metric.Gauge`.

  A Counter is typically used to count requests served, tasks completed, errors
  occurred, etc.

  Example use cases for Counters:
    - Number of requests processed;
    - Number of items that were inserted into a queue;
    - Total amount of data that a system has processed.

  Use the [`rate()`](https://prometheus.io/docs/querying/functions/#rate())/
  [`irate()`](https://prometheus.io/docs/querying/functions/#irate())
  functions in Prometheus to calculate the rate of increase of a Counter.
  By convention, the names of Counters are suffixed by `_total`.

  To create a counter use either `new/1` or `declare/`, the difference is that
  `new/` will raise `Prometheus.Error.MFAlreadyExists` exception if counter with
  the same `registry`, `name` and `labels` combination already exists.
  Both accept `spec` `Keyword` with the same set of keys:

  - `:registry` - optional, default is `:default`;
  - `:name` - required, can be an atom or a string;
  - `:help` - required, must be a string;
  - `:labels` - optional, default is `[]`.

  Example:

  ```
  defmodule MyServiceInstrumenter do

    use Prometheus.Metric

    ## to be called at app/supervisor startup.
    ## to tolerate restarts use declare.
    def setup() do
      Counter.declare([name: :my_service_total_requests,
                       help: "Total requests.",
                       labels: [:caller]])
    end

    def inc(caller) do
      Counter.inc([name: :my_service_total_requests,
                   labels: [caller]])
    end

  end

  ```

  """

  alias Prometheus.Metric
  require Prometheus.Error

  @doc """
  Creates a counter using `spec`.

  Raises `Prometheus.Error.MissingMetricSpecKey` if required `spec` key is missing.<br>
  Raises `Prometheus.Error.InvalidMetricName` if metric name is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricHelp` if help is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricLabels` if labels isn't a list.<br>
  Raises `Prometheus.Error.InvalidMetricName` if label name is invalid.<br>
  Raises `Prometheus.Error.MFAlreadyExists` if a counter with the same `spec` already exists.
  """
  defmacro new(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.new(unquote(spec))
      )
    end
  end

  @doc """
  Creates a counter using `spec`.
  If a counter with the same `spec` exists returns `false`.

  Raises `Prometheus.Error.MissingMetricSpecKey` if required `spec` key is missing.<br>
  Raises `Prometheus.Error.InvalidMetricName` if metric name is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricHelp` if help is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricLabels` if labels isn't a list.<br>
  Raises `Prometheus.Error.InvalidMetricName` if label name is invalid.
  """
  defmacro declare(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.declare(unquote(spec))
      )
    end
  end

  @doc """
  Increments the counter identified by `spec` by `value`.

  Raises `Prometheus.Error.InvalidValue` exception if `value` isn't a positive integer.<br>
  Raises `Prometheus.Error.UnknownMetric` exception if a counter for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro inc(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.inc(unquote(registry), unquote(name), unquote(labels),  unquote(value))
      )
    end
  end

  @doc """
  Increments the counter identified by `spec` by `value`.
  If `value` happened to be a float number even one time(!) you shouldn't use `inc/2` after dinc.

  Raises `Prometheus.Error.InvalidValue` exception if `value` isn't a positive number.<br>
  Raises `Prometheus.Error.UnknownMetric` exception if a counter for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro dinc(spec, value \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.dinc(unquote(registry), unquote(name), unquote(labels),  unquote(value))
      )
    end
  end

  @doc """
  Resets the value of the counter identified by `spec`.

  Raises `Prometheus.Error.UnknownMetric` exception if a counter for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.reset(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end

  @doc """
  Returns the value of the counter identified by `spec`. If there is no counter for
  given labels combination, returns `:undefined`.

  Raises `Prometheus.Error.UnknownMetric` exception if a counter for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_counter.value(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end
end
