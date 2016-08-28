defmodule Prometheus.Format.Protobuf do
  @moduledoc """
  Serializes Prometheus registry using Protocol buffer format.
  """

  require Prometheus.Error

  @doc """
  Content type of Protocol buffer format.
  """
  def content_type do
    require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
      :prometheus_protobuf_format.content_type
    )
  end

  @doc """
  Format `registry` (default is `:default`) using Protocol buffer format.
  """
  def format(registry \\ :default) do
    require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
      :prometheus_protobuf_format.format(registry)
    )
  end

end
