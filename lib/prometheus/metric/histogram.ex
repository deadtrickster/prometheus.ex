defmodule Prometheus.Metric.Histogram do
  @moduledoc """
  A Histogram tracks the size and number of events in buckets.
  You can use Histograms for aggregatable calculation of quantiles.

  Example use cases for Histograms:
    - Response latency;
    - Request size.

  Histogram expects `buckets` key in a metric spec. Buckets can be:
   - a list of numbers in increasing order;
   - on of the generate specs (essentially shortcuts for `Prometheus.Buckets` macros)
       - :default;
       - {:linear, start, step, count};
       - {:exponential, start, step, count}.

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
                     help: "Http Request execution time"])
    end

    def instrument(%{time: time, method: method}) do
      Histogram.observe([name: :http_request_duration_milliseconds, labels: [method]], time)
    end
  end

  ```

  """

  use Prometheus.Erlang, :prometheus_histogram

  @doc """
  Creates a histogram using `spec`.
  Histogram cannot have a label named "le".

  Raises `Prometheus.Error.MissingMetricSpecKey` if required `spec` key is missing.<br>
  Raises `Prometheus.Error.InvalidMetricName` if metric name is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricHelp` if help is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricLabels` if labels isn't a list.<br>
  Raises `Prometheus.Error.InvalidMetricName` if label name is invalid.
  Raises `Prometheus.Error.MFAlreadyExists` if a histogram with the same `spec` exists.

  Histogram Specific exceptions:

  Raises `Prometheus.Error.HistogramNoBuckets` if buckets are missing, not a list, empty list or not known buckets spec.<br>
  Raises `Prometheus.Error.HistogramInvalidBuckets` if buckets aren't in increasing order.<br>
  Raises `Prometheus.Error.HistogramInvalidBound` if bucket bound isn't a number.
  """
  defmacro new(spec) do
    Erlang.call([spec])
  end

  @doc """
  Creates a histogram using `spec`.
  Histogram cannot have a label named "le".

  If a histogram with the same `spec` exists returns `false`.

  Raises `Prometheus.Error.MissingMetricSpecKey` if required `spec` key is missing.<br>
  Raises `Prometheus.Error.InvalidMetricName` if metric name is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricHelp` if help is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricLabels` if labels isn't a list.<br>
  Raises `Prometheus.Error.InvalidMetricName` if label name is invalid.

  Histogram Specific exceptions:

  Raises `Prometheus.Error.HistogramNoBuckets` if buckets are missing, not a list, empty list or not known buckets spec.<br>
  Raises `Prometheus.Error.HistogramInvalidBuckets` if buckets aren't in increasing order.<br>
  Raises `Prometheus.Error.HistogramInvalidBound` if bucket bound isn't a number.
  """
  defmacro declare(spec) do
    Erlang.call([spec])
  end

  @doc """
  Observes the given amount.

  Raises `Prometheus.Error.InvalidValue` exception if `amount` isn't a positive integer.<br>
  Raises `Prometheus.Error.UnknownMetric` exception if a histogram for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro observe(spec, amount \\ 1) do
    Erlang.metric_call(spec, [amount])
  end

  @doc """
  Observes the given amount.
  If `amount` happened to be a float number even one time(!) you shouldn't use `observe/2` after dobserve.

  Raises `Prometheus.Error.InvalidValue` exception if `amount` isn't a positive integer.<br>
  Raises `Prometheus.Error.UnknownMetric` exception if a histogram for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro dobserve(spec, amount \\ 1) do
    Erlang.metric_call(spec, [amount])
  end

  @doc """
  Observes the amount of microseconds spent executing `fun`.

  Raises `Prometheus.Error.UnknownMetric` exception if a histogram for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro observe_duration(spec, fun) do
    Erlang.metric_call(spec, [fun])
  end

  @doc """
  Resets the value of the histogram identified by `spec`.

  Raises `Prometheus.Error.UnknownMetric` exception if a histogram for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro reset(spec) do
    Erlang.metric_call(spec)
  end

  @doc """
  Returns the value of the histogram identified by `spec`. If there is no histogram for
  given labels combination, returns `:undefined`.

  Raises `Prometheus.Error.UnknownMetric` exception if a histogram for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro value(spec) do
    Erlang.metric_call(spec)
  end
end
