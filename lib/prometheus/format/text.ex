defmodule Prometheus.Format.Text do
  @moduledoc """
  Serializes Prometheus registry using the latest [text format](http://bit.ly/2cxSuJP).

  Example output:
  ```
  # TYPE http_request_duration_milliseconds histogram
  # HELP http_request_duration_milliseconds Http Request execution time
  http_request_duration_milliseconds_bucket{method="post",le="100"} 0
  http_request_duration_milliseconds_bucket{method="post",le="300"} 1
  http_request_duration_milliseconds_bucket{method="post",le="500"} 3
  http_request_duration_milliseconds_bucket{method="post",le="750"} 4
  http_request_duration_milliseconds_bucket{method="post",le="1000"} 5
  http_request_duration_milliseconds_bucket{method="post",le="+Inf"} 6
  http_request_duration_milliseconds_count{method="post"} 6
  http_request_duration_milliseconds_sum{method="post"} 4350
  ```
  """
  require Prometheus.Error

  @doc """
  Returns content type of the latest text format.
  """
  def content_type do
    require Prometheus.Error
    Prometheus.Error.with_prometheus_error(:prometheus_text_format.content_type())
  end

  @doc """
  Formats `registry` (default is `:default`) using the latest text format.
  """
  def format(registry \\ :default) do
    require Prometheus.Error
    Prometheus.Error.with_prometheus_error(:prometheus_text_format.format(registry))
  end
end
