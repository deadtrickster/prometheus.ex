defmodule Prometheus.Contrib.HTTPTest do
  use ExUnit.Case
  ## alias Prometheus.Error %% FIXME: status_class should throw invalid_value.
  use Prometheus
  
  doctest Prometheus.Contrib.HTTP

  test "microseconds_duration_buckets" do
    assert [10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000,
            100000, 250000, 500000, 1000000, 2500000, 5000000, 10000000] == Prometheus.Contrib.HTTP.microseconds_duration_buckets
  end

  test "status_class" do
    assert 'unknown' == Prometheus.Contrib.HTTP.status_class(50)
    assert 'informational' == Prometheus.Contrib.HTTP.status_class(150)
    assert 'success' == Prometheus.Contrib.HTTP.status_class(250)
    assert 'redirection' == Prometheus.Contrib.HTTP.status_class(350)
    assert 'client-error' == Prometheus.Contrib.HTTP.status_class(450)
    assert 'server-error' == Prometheus.Contrib.HTTP.status_class(550)
    assert 'unknown' == Prometheus.Contrib.HTTP.status_class(650)
  end

end
