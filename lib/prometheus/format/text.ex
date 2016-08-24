defmodule Prometheus.Format.Text do

  def content_type do
    :prometheus_text_format.content_type
  end

  def format(registry \\ :default) do
    :prometheus_text_format.format(registry)
  end
  
end
