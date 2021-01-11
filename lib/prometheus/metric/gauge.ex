defmodule Prometheus.Metric.Gauge do
  @moduledoc """
  Gauge metric, to report instantaneous values.

  Gauge is a metric that represents a single numerical value that can
  arbitrarily go up and down.

  A Gauge is typically used for measured values like temperatures or current
  memory usage, but also "counts" that can go up and down, like the number of
  running processes.

  Example use cases for Gauges:
    - In progress requests;
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
      Gauge.track_inprogress([name: :my_pool_checked_out], checkout_fun.())
    end

    def track_checked_out_sockets_block(socket) do
      Gauge.track_inprogress([name: :my_pool_checked_out]) do
        # checkout code
        socket
      end
    end

  end

  ```

  """

  use Prometheus.Erlang, :prometheus_gauge

  @doc """
  Creates a gauge using `spec`.

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidMetricNameError` if label name is invalid.<br>
  Raises `Prometheus.InvalidValueError` exception if duration_unit is unknown or
  doesn't match metric name.<br>
  Raises `Prometheus.MFAlreadyExistsError` if a gauge with the same `spec` exists.
  """
  delegate new(spec)

  @doc """
  Creates a gauge using `spec`.
  If a gauge with the same `spec` exists returns `false`.

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidMetricNameError` if label name is invalid.<br>
  Raises `Prometheus.InvalidValueError` exception if duration_unit is unknown or
  doesn't match metric name.
  """
  delegate declare(spec)

  @doc """
  Sets the gauge identified by `spec` to `value`.

  Raises `Prometheus.InvalidValueError` exception if `value` isn't
  a number or `:undefined`.<br>
  Raises `Prometheus.UnknownMetricError` exception if a gauge for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric set(spec, value)

  @doc """
  Increments the gauge identified by `spec` by `value`.

  Raises `Prometheus.InvalidValueError` exception if `value` isn't a number.<br>
  Raises `Prometheus.UnknownMetricError` exception if a gauge for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric inc(spec, value \\ 1)

  @doc """
  Decrements the gauge identified by `spec` by `value`.

  Raises `Prometheus.InvalidValueError` exception if `value` isn't a number.<br>
  Raises `Prometheus.UnknownMetricError` exception if a gauge for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric dec(spec, value \\ 1)

  @doc """
  Sets the gauge identified by `spec` to the current unix time.

  Raises `Prometheus.UnknownMetricError` exception if a gauge
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric set_to_current_time(spec)

  @doc """
  Sets the gauge identified by `spec` to the number of currently executing `body`s.

  Raises `Prometheus.UnknownMetricError` exception if a gauge
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  Raises `Prometheus.InvalidValueError` exception if fun isn't a function or block.
  """
  defmacro track_inprogress(spec, body) do
    env = __CALLER__

    Prometheus.Injector.inject(
      fn block ->
        quote do
          Prometheus.Metric.Gauge.inc(unquote(spec))

          try do
            unquote(block)
          after
            Prometheus.Metric.Gauge.dec(unquote(spec))
          end
        end
      end,
      env,
      body
    )
  end

  @doc """
  Tracks the amount of time spent executing `body`.

  Raises `Prometheus.UnknownMetricError` exception if a gauge
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  Raises `Prometheus.InvalidValueError` exception if `fun` isn't a function or block.
  """
  defmacro set_duration(spec, body) do
    env = __CALLER__

    Prometheus.Injector.inject(
      fn block ->
        quote do
          start_time = :erlang.monotonic_time()

          try do
            unquote(block)
          after
            end_time = :erlang.monotonic_time()
            Prometheus.Metric.Gauge.set(unquote(spec), end_time - start_time)
          end
        end
      end,
      env,
      body
    )
  end

  @doc """
  Removes gauge series identified by spec.

  Raises `Prometheus.UnknownMetricError` exception if a gauge
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric remove(spec)

  @doc """
  Resets the value of the gauge identified by `spec`.

  Raises `Prometheus.UnknownMetricError` exception if a gauge
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric reset(spec)

  @doc """
  Returns the value of the gauge identified by `spec`.

  If duration unit set, value will be converted to the duration unit.
  [Read more here.](time.html)

  Raises `Prometheus.UnknownMetricError` exception if a gauge
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric value(spec)
end
