defmodule Prometheus.Metric.QuantileSummary do
  @moduledoc """
  Quantile summary metric, measuring count, summary, 0.5, 0.9 and 0.95 quantiles.

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
      QuantileSummary.declare([name: :request_size_bytes,
                       help: "Request size in bytes."])

      QuantileSummary.declare([name: :response_size_bytes,
                       help: "Response size in bytes."])
    end

    def observe_request(size) do
      QuantileSummary.observe([name: :request_size_bytes], size)
    end

    def observe_response(size) do
      QuantileSummary.observe([name: :response_size_bytes], size)
    end
  end
  ```

  """

  use Prometheus.Erlang, :prometheus_quantile_summary

  @doc """
  Creates a quantile summary using `spec`.
  Summary cannot have a label named "quantile".

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidMetricNameError` if label name is invalid.<br>
  Raises `Prometheus.InvalidValueError` exception if duration_unit is unknown or
  doesn't match metric name.<br>
  Raises `Prometheus.MFAlreadyExistsError` if a summary with the same `spec`
  already exists.
  """
  delegate(new(spec))

  @doc """
  Creates a quantile summary using `spec`.
  Summary cannot have a label named "quantile".

  If a quantile summary with the same `spec` exists returns `false`.

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidMetricNameError` if label name is invalid;<br>
  Raises `Prometheus.InvalidValueError` exception if duration_unit is unknown or
  doesn't match metric name.
  """
  delegate(declare(spec))

  @doc """
  Observes the given amount.

  Raises `Prometheus.InvalidValueError` exception if `amount` isn't a number.<br>
  Raises `Prometheus.UnknownMetricError` exception if a quantile summary for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric(observe(spec, amount \\ 1))

  @doc """
  Observes the amount of time spent executing `body`.

  Raises `Prometheus.UnknownMetricError` exception if a quantile summary for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  Raises `Prometheus.InvalidValueError` exception if `fun` isn't a function or block.
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

            Prometheus.Metric.QuantileSummary.observe(
              unquote(spec),
              end_time - start_time
            )
          end
        end
      end,
      env,
      body
    )
  end

  @doc """
  Removes quantile summary series identified by spec.

  Raises `Prometheus.UnknownMetricError` exception if a quantile summary for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric(remove(spec))

  @doc """
  Resets the value of the quantile summary identified by `spec`.

  Raises `Prometheus.UnknownMetricError` exception if a quantile summary for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric(reset(spec))

  @doc """
  Returns the value of the quantile summary identified by `spec`. If there is no quantile summary for
  given labels combination, returns `:undefined`.

  If duration unit set, sum will be converted to the duration unit.
  [Read more here.](time.html)

  Raises `Prometheus.UnknownMetricError` exception if a quantile summary for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric(value(spec))
end
