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
  defmacro exists(name) do
    Erlang.call([name])
  end

  @doc """
  Calls `callback` for each collector with two arguments: `registry` and `collector`.
  """
  defmacro collect(callback, registry \\ :default) do
    Erlang.call([registry, callback])
  end

  @doc """
  Returns collectors registered in `registry`.
  """
  defmacro collectors(registry \\ :default) do
    Erlang.call([registry])
  end

  @doc """
  Registers a collector.
  """
  defmacro register_collector(registry \\ :default, collector) do
    Erlang.call([registry, collector])
  end

  @doc """
  Registers collectors list.
  """
  defmacro register_collectors(registry \\ :default, collectors) do
    Erlang.call([registry, collectors])
  end

  @doc """
  Unregisters a collector.
  """
  defmacro deregister_collector(registry \\ :default, collector) do
    Erlang.call([registry, collector])
  end

  @doc """
  Unregisters all collectors.
  """
  defmacro clear(registry \\ :default) do
    Erlang.call([registry])
  end

  @doc """
  Checks whether `collector` is registered.
  """
  defmacro collector_registered?(registry \\ :default, collector) do
    Erlang.call(:collector_registeredp, [registry, collector])
  end
end
