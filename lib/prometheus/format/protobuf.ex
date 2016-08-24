defmodule Prometheus.Format.Protobuf do

  require Prometheus.Error

  def content_type do
    require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
      :prometheus_protobuf_format.content_type
    )
  end

  def format(registry \\ :default) do
    require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
      :prometheus_protobuf_format.format(registry)
    )
  end

end
