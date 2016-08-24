defmodule Prometheus.Format.Text do

  require Prometheus.Error

  def content_type do
    require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
      :prometheus_text_format.content_type
    )
  end

  def format(registry \\ :default) do
    require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
      :prometheus_text_format.format(registry)
    )
  end

end
