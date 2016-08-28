defmodule Prometheus.Contrib.HTTP do
  @moduledoc """
  HTTP instrumentation helpers
  """

  @doc """
  Default microseconds buckets for measuring http requests duration:

      iex(6)> Prometheus.Contrib.HTTP.microseconds_duration_buckets
      [10, 100, 1000, 10000, 100000, 300000, 500000, 750000, 1000000, 1500000,
       2000000, 3000000]

  """
  defmacro microseconds_duration_buckets do
    :prometheus_http.microseconds_duration_buckets
  end

  @doc """
  Returns class of http status code:

      iex(7)> Prometheus.Contrib.HTTP.status_class(202)
      'success'

  The function raises `Prometheus.Error.InvalidValue` exception if `code` is not a positive integer.
  """
  defmacro status_class(code) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
	:prometheus_http.status_class(unquote(code))
      )
    end
  end
end
