defmodule Prometheus.Metric.Histogram do
  @moduledoc """
  A Histogram tracks the size and number of events in buckets.
  You can use Histograms for aggregating calculation of quantiles.

  Example use cases for Histograms:
    - Response latency;
    - Request size.

  Histogram expects `buckets` key in a metric spec. Buckets can be:
   - a list of numbers in increasing order;
   - one of the generate specs (shortcuts for `Prometheus.Buckets` macros)
       - `:default`;
       - `{:linear, start, step, count}`;
       - `{:exponential, start, step, count}`.

  Example:

  ```

  defmodule ExampleInstrumenter do
    use Prometheus.Metric

    ## to be called at app/supervisor startup.
    ## to tolerate restarts use declare.
    def setup do
      Histogram.new([name: :http_request_duration_milliseconds,
                     labels: [:method],
                     buckets: [100, 300, 500, 750, 1000],
                     help: "Http Request execution time."])
    end

    def instrument(%{time: time, method: method}) do
      Histogram.observe([name: :http_request_duration_milliseconds, labels: [method]],
                        time)
    end
  end

  ```

  """

  use Prometheus.Erlang, :prometheus_histogram

  @doc """
  Creates a histogram using `spec`.
  Histogram cannot have a label named "le".

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidMetricNameError` if label name is invalid.<br>
  Raises `Prometheus.InvalidValueError` exception if duration_unit is unknown or
  doesn't match metric name.<br>
  Raises `Prometheus.MFAlreadyExistsError` if a histogram with the same `spec` exists.

  Histogram-specific exceptions:

  Raises `Prometheus.HistogramNoBucketsError` if buckets are missing, not a list,
  empty list or not known buckets spec.<br>
  Raises `Prometheus.HistogramInvalidBucketsError` if buckets aren't
  in increasing order.<br>
  Raises `Prometheus.HistogramInvalidBoundError` if bucket bound isn't a number.
  """
  delegate new(spec)

  @doc """
  Creates a histogram using `spec`.
  Histogram cannot have a label named "le".

  If a histogram with the same `spec` exists returns `false`.

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidMetricNameError` if label name is invalid.<br>
  Raises `Prometheus.InvalidValueError` exception if duration_unit is unknown or
  doesn't match metric name.

  Histogram-specific exceptions:

  Raises `Prometheus.HistogramNoBucketsError` if buckets are missing, not a list,
  empty list or not known buckets spec.<br>
  Raises `Prometheus.HistogramInvalidBucketsError` if buckets aren't
  in increasing order.<br>
  Raises `Prometheus.HistogramInvalidBoundError` if bucket bound isn't a number.
  """
  delegate declare(spec)

  @doc """
  Observes the given amount.

  Raises `Prometheus.InvalidValueError` exception if `amount` isn't
  a number.<br>
  Raises `Prometheus.UnknownMetricError` exception if a histogram for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric observe(spec, amount \\ 1)

  @doc """
  Observes the amount of time spent executing `body`.

  Raises `Prometheus.UnknownMetricError` exception if a histogram for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  Raises `Prometheus.InvalidValueError` exception if fun isn't a function or block.
  """
  defmacro observe_duration(spec, body) do
    env = __CALLER__

    Prometheus.Injector.inject(
      fn block ->
        quote do
          start_time = :erlang.monotonic_time()

          try do
            unquote(block)
          after
            end_time = :erlang.monotonic_time()
            Prometheus.Metric.Histogram.observe(unquote(spec), end_time - start_time)
          end
        end
      end,
      env,
      body
    )
  end

  @doc """
  Removes histogram series identified by spec.

  Raises `Prometheus.UnknownMetricError` exception if a histogram for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric remove(spec)

  @doc """
  Resets the value of the histogram identified by `spec`.

  Raises `Prometheus.UnknownMetricError` exception if a histogram for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric reset(spec)

  @doc """
  Returns the value of the histogram identified by `spec`. If there is no histogram for
  given labels combination, returns `:undefined`.

  Raises `Prometheus.UnknownMetricError` exception if a histogram for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric value(spec)
end
