defmodule Prometheus.Contrib.HTTP do
  defmacro microseconds_duration_buckets do
    :prometheus_http.microseconds_duration_buckets
  end

  defmacro status_class(code) do
    quote do
      :prometheus_http.status_class(unquote(code))
    end
  end
end
