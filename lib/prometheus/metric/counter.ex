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

  To create a counter use either `new/1` or `declare/1`, the difference is that
  `new/` will raise `Prometheus.MFAlreadyExistsError` exception if counter with
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
      Counter.declare([name: :my_service_requests_total,
                       help: "Requests count.",
                       labels: [:caller]])
    end

    def inc(caller) do
      Counter.inc([name: :my_service_requests_total,
                  labels: [caller]])
    end

  end

  ```

  """

  use Prometheus.Erlang, :prometheus_counter

  @doc """
  Creates a counter using `spec`.

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidLabelNameError` if label name is invalid.<br>
  Raises `Prometheus.MFAlreadyExistsError` if a counter with
  the same `spec` already exists.
  """
  delegate new(spec)

  @doc """
  Creates a counter using `spec`.
  If a counter with the same `spec` exists returns `false`.

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidLabelNameError` if label name is invalid.
  """
  delegate declare(spec)

  @doc """
  Increments the counter identified by `spec` by `value`.

  Raises `Prometheus.InvalidValueError` exception if `value` isn't a positive number.<br>
  Raises `Prometheus.UnknownMetricError` exception if a counter
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric inc(spec, value \\ 1)

  @doc """
  Increments the counter identified by `spec` by 1 when `body` executed.

  Read more about bodies: `Prometheus.Injector`.

  Raises `Prometheus.UnknownMetricError` exception if a counter
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  defmacro count(spec, body) do
    env = __CALLER__

    Prometheus.Injector.inject(
      fn block ->
        quote do
          Prometheus.Metric.Counter.inc(unquote(spec), 1)
          unquote(block)
        end
      end,
      env,
      body
    )
  end

  @doc """
  Increments the counter identified by `spec` by 1 when `body` raises `exception`.

  Read more about bodies: `Prometheus.Injector`.

  Raises `Prometheus.UnknownMetricError` exception if a counter
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  defmacro count_exceptions(spec, exception \\ :_, body) do
    env = __CALLER__

    Prometheus.Injector.inject(
      fn block ->
        quote do
          require Prometheus.Error

          Prometheus.Error.with_prometheus_error(
            try do
              unquote(block)
            rescue
              e in unquote(exception) ->
                stacktrace = unquote(quote(do: __STACKTRACE__))

                {registry, name, labels} = Prometheus.Metric.parse_spec(unquote(spec))
                :prometheus_counter.inc(registry, name, labels, 1)
                reraise(e, stacktrace)
            end
          )
        end
      end,
      env,
      body
    )
  end

  @doc """
  Increments the counter identified by `spec` by 1 when `body` raises no exceptions.

  Read more about bodies: `Prometheus.Injector`.

  Raises `Prometheus.UnknownMetricError` exception if a counter
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  defmacro count_no_exceptions(spec, body) do
    env = __CALLER__

    Prometheus.Injector.inject(
      fn block ->
        quote do
          require Prometheus.Error

          value =  unquote(block)
          Prometheus.Metric.Counter.inc(unquote(spec), 1)
          value
        end
      end,
      env,
      body
    )
  end

  @doc """
  Removes counter series identified by spec.

  Raises `Prometheus.UnknownMetricError` exception if a counter
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric remove(spec)

  @doc """
  Resets the value of the counter identified by `spec`.

  Raises `Prometheus.UnknownMetricError` exception if a counter
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric reset(spec)

  @doc """
  Returns the value of the counter identified by `spec`. If there is no counter for
  given labels combination, returns `:undefined`.

  Raises `Prometheus.UnknownMetricError` exception if a counter
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric value(spec)
end
