defmodule Prometheus.Metric.Summary do
  @moduledoc """
  Summary metric, to track the size of events.

  Example use cases for Summaries:
    - Response latency;
    - Request size;
    - Response size.

  Example:

  ```
  defmodule MyProxyInstrumenter do

    use Prometheus.Metric

    ## to be called at app/supervisor startup.
    ## to tolerate restarts use declare.
    def setup() do
      Summary.declare([name: :request_size_bytes,
                       help: "Request size in bytes."])

      Summary.declare([name: :response_size_bytes,
                       help: "Response size in bytes."])
    end

    def observe_request(size) do
      Summary.observe([name: :request_size_bytes], size)
    end

    def observe_response(size) do
      Summary.observe([name: :response_size_bytes], size)
    end
  end
  ```

  """

  alias Prometheus.Metric
  require Prometheus.Error

  @doc """
  Creates a summary using `spec`.
  Summary cannot have a label named "quantile".

  Raises `Prometheus.Error.MissingMetricSpecKey` if required `spec` key is missing.<br>
  Raises `Prometheus.Error.InvalidMetricName` if metric name is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricHelp` if help is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricLabels` if labels isn't a list.<br>
  Raises `Prometheus.Error.InvalidMetricName` if label name is invalid.<br>
  Raises `Prometheus.Error.MFAlreadyExists` if a summary with the same `spec` already exists.
  """
  defmacro new(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.new(unquote(spec))
      )
    end
  end

  @doc """
  Creates a summary using `spec`.
  Summary cannot have a label named "quantile".

  If a summary with the same `spec` exists returns `false`.

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
        :prometheus_summary.declare(unquote(spec))
      )
    end
  end

  @doc """
  Observes the given amount.

  Raises `Prometheus.Error.InvalidValue` exception if `amount` isn't a positive integer.<br>
  Raises `Prometheus.Error.UnknownMetric` exception if a summary for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro observe(spec, amount \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.observe(unquote(registry),
          unquote(name), unquote(labels),  unquote(amount))
      )
    end
  end

  @doc """
  Observes the given amount.
  If `amount` happened to be a float number even one time(!) you shouldn't use `observe/2` after dobserve.

  Raises `Prometheus.Error.InvalidValue` exception if `amount` isn't a positive integer.<br>
  Raises `Prometheus.Error.UnknownMetric` exception if a summary for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro dobserve(spec, amount \\ 1) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.dobserve(unquote(registry),
          unquote(name), unquote(labels), unquote(amount))
      )
    end
  end

  @doc """
  Observes the amount of microseconds spent executing `fun`.

  Raises `Prometheus.Error.UnknownMetric` exception if a summary for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro observe_duration(spec, fun) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.observe_duration(unquote(registry),
          unquote(name), unquote(labels), unquote(fun))
      )
    end
  end

  @doc """
  Resets the value of the summary identified by `spec`.

  Raises `Prometheus.Error.UnknownMetric` exception if a summary for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.reset(unquote(registry),
          unquote(name), unquote(labels))
      )
    end
  end

  @doc """
  Returns the value of the summary identified by `spec`. If there is no summary for
  given labels combination, returns `:undefined`.

  Raises `Prometheus.Error.UnknownMetric` exception if a summary for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_summary.value(unquote(registry),
          unquote(name), unquote(labels))
      )
    end
  end
end
