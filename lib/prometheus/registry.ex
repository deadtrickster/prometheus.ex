defmodule Prometheus.Registry do
  @moduledoc """
  A registry of Collectors.

  The majority of users should use the `:default`, rather than their own.

  Creating a registry other than the default is primarily useful for
  unit tests, or pushing a subset of metrics to the
  [Pushgateway](https://github.com/prometheus/pushgateway) from batch jobs.
  """

  use Prometheus.Erlang, :prometheus_registry

  @doc """
  Tries to find registry with the `name`.
  Assumes that registry name is always an atom.
  If `Name` is an atom `ets:lookup/2` is used
  If `Name` is an iolist performs safe search (to avoid interning
  atoms) and returns atom or false. This operation is O(n).
  """
  delegate exists(name)

  @doc """
  Calls `callback` for each collector with two arguments: `registry` and `collector`.
  """
  delegate collect(callback, registry \\ :default)

  @doc """
  Returns collectors registered in `registry`.
  """
  delegate collectors(registry \\ :default)

  @doc """
  Registers a collector.
  """
  delegate register_collector(registry \\ :default, collector)

  @doc """
  Registers collectors list.
  """
  delegate register_collectors(registry \\ :default, collectors)

  @doc """
  Unregisters a collector.
  """
  delegate deregister_collector(registry \\ :default, collector)

  @doc """
  Unregisters all collectors.
  """
  delegate clear(registry \\ :default)

  @doc """
  Checks whether `collector` is registered.
  """
  delegate collector_registered?(registry \\ :default, collector),
    as: :collector_registeredp
end
