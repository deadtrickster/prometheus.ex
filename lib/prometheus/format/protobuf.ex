defmodule Prometheus.Format.Protobuf do

  def content_type do
    :prometheus_protobuf_format.content_type
  end

  def format(registry \\ :default) do
    :prometheus_protobuf_format.format(registry)
  end
  
end
