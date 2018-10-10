defmodule Prometheus.Metric.Boolean do
  @moduledoc """
  Boolean metric, to report booleans and flags.

  Boolean is a non-standard metric that uses untyped metric underneath.

  A Boolean is typically used as a flag i.e. enabled/disabled, online/offline.

  Example:
  ```
  -module(my_fuse_instrumenter).

  -export([setup/0,
           fuse_event/2]).

   setup() ->
     prometheus_boolean:declare([{name, app_fuse_state},
                                 {labels, [name]}, %% fuse name
                                 {help, "State of various app fuses."}]),

   fuse_event(Fuse, Event) ->
     case Event of
       ok -> prometheus_boolean:set(app_fuse_state, [Fuse], true);
       blown -> prometheus_boolean:set(app_fuse_state, [Fuse], false);
       _ -> ok
     end.
     ```
  """

  use Prometheus.Erlang, :prometheus_boolean

  @doc """
  Creates a boolean using `spec`.

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidLabelNameError` if label name is invalid.<br>
  Raises `Prometheus.MFAlreadyExistsError` if a boolean with
  the same `spec` already exists.
  """
  delegate new(spec)

  @doc """
  Creates a boolean using `spec`.
  If a boolean with the same `spec` exists returns `false`.

  Raises `Prometheus.MissingMetricSpecKeyError` if required `spec` key is missing.<br>
  Raises `Prometheus.InvalidMetricNameError` if metric name is invalid.<br>
  Raises `Prometheus.InvalidMetricHelpError` if help is invalid.<br>
  Raises `Prometheus.InvalidMetricLabelsError` if labels isn't a list.<br>
  Raises `Prometheus.InvalidLabelNameError` if label name is invalid.
  """
  delegate declare(spec)

  @doc """
  Sets the boolean identified by `spec` to `value`.

  Valid "truthy" values:
  - `true`;
  - `false`;
  - `0` -> false;
  - `number > 0` -> true;
  - `[]` -> false
  - `non-empty list` -> true;
  - `:undefined` -> undefined

  Other values will generate `Prometheus.InvalidValueError` error.

  Raises `Prometheus.InvalidValueError` exception if `value` isn't
  a boolean or `:undefined`.<br>
  Raises `Prometheus.UnknownMetricError` exception if a boolean for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric set(spec, value)

  @doc """
  Toggles the boolean identified by `spec` to `value`.

  Raises `Prometheus.InvalidValueError` exception if boolean is `:undefined`.<br>
  Raises `Prometheus.UnknownMetricError` exception if a boolean for `spec`
  can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric toggle(spec)

  @doc """
  Removes boolean series identified by spec.

  Raises `Prometheus.UnknownMetricError` exception if a boolean
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric remove(spec)

  @doc """
  Resets the value of the boolean identified by `spec`.

  Raises `Prometheus.UnknownMetricError` exception if a boolean
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric reset(spec)

  @doc """
  Returns the value of the boolean identified by `spec`. If there is no boolean for
  given labels combination, returns `:undefined`.

  Raises `Prometheus.UnknownMetricError` exception if a boolean
  for `spec` can't be found.<br>
  Raises `Prometheus.InvalidMetricArityError` exception if labels count mismatch.
  """
  delegate_metric value(spec)
end
