defmodule Prometheus.Metric.Gauge do
  @moduledoc """
  Gauge metric, to report instantaneous values.

  Gauge is a metric that represents a single numerical value that can
  arbitrarily go up and down.

  A Gauge is typically used for measured values like temperatures or current
  memory usage, but also "counts" that can go up and down, like the number of
  running processes.

  Example use cases for Gauges:
    - Inprogress requests;
    - Number of items in a queue;
    - Free memory;
    - Total memory;
    - Temperature.

  Example:

  ```
  defmodule MyPoolInstrumenter do

    use Prometheus.Metric

    ## to be called at app/supervisor startup.
    ## to tolerate restarts use declare.
    def setup() do
      Gauge.declare([name: :my_pool_size,
                     help: "Pool size."])

      Gauge.declare([name: :my_pool_checked_out,
                     help: "Number of sockets checked out from the pool"])
    end

    def set_size(size) do
      Gauge.set([name: :my_pool_size], size)
    end

    def track_checked_out_sockets(checkout_fun) do
      Gauge.track_inprogress([name: :my_pool_checked_out], checkout_fun)
    end

  end

  ```

  """

  alias Prometheus.Metric
  require Prometheus.Error

  @doc """
  Creates a gauge using `spec`.

  Raises `Prometheus.Error.MissingMetricSpecKey` if required `spec` key is missing.<br>
  Raises `Prometheus.Error.InvalidMetricName` if metric name is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricHelp` if help is invalid.<br>
  Raises `Prometheus.Error.InvalidMetricLabels` if labels isn't a list.<br>
  Raises `Prometheus.Error.InvalidMetricName` if label name is invalid.<br>
  Raises `Prometheus.Error.MFAlreadyExists` if a gauge with the same `spec` exists.
  """
  defmacro new(spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.new(unquote(spec))
      )
    end
  end

  @doc """
  Creates a gauge using `spec`.
  If a gauge with the same `spec` exists returns `false`.

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
        :prometheus_gauge.declare(unquote(spec))
      )
    end
  end

  @doc """
  Sets the gauge identified by `spec` to `value`.

  Raises `Prometheus.Error.InvalidValue` exception if `value` isn't a number.<br>
  Raises `Prometheus.Error.UnknownMetric` exception if a gauge for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro set(spec, value) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.set(unquote(registry), unquote(name), unquote(labels),  unquote(value))
      )
    end
  end

  @doc """
  Sets the gauge identified by `spec` to the current unixtime.

  Raises `Prometheus.Error.UnknownMetric` exception if a gauge for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro set_to_current_time(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.set_to_current_time(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end

  @doc """
  Track inprogress functions.

  Raises `Prometheus.Error.UnknownMetric` exception if a gauge for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro track_inprogress(spec, fun) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.track_inprogress(unquote(registry), unquote(name), unquote(labels), unquote(fun))
      )
    end
  end

  @doc """
  Resets the value of the gauge identified by `spec`.

  Raises `Prometheus.Error.UnknownMetric` exception if a gauge for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro reset(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.reset(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end

  @doc """
  Returns the value of the gauge identified by `spec`.

  Raises `Prometheus.Error.UnknownMetric` exception if a gauge for `spec` can't be found.<br>
  Raises `Prometheus.Error.InvalidMetricArity` exception if labels count mismatch.
  """
  defmacro value(spec) do
    {registry, name, labels} = Metric.parse_spec(spec)

    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        :prometheus_gauge.value(unquote(registry), unquote(name), unquote(labels))
      )
    end
  end
end

