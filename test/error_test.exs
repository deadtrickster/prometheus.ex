defmodule Prometheus.ErrorTest do

  use Prometheus.Case

  def erlang_error do
    raise ErlangError
  end

  test "properly proxies unknown exceptions" do
    assert_raise ArgumentError,
    fn ->
      Prometheus.Error.with_prometheus_error :ets.tab2list(:qweqweqwe)
    end

    assert_raise ErlangError,
    fn ->
      Prometheus.Error.with_prometheus_error erlang_error
    end
  end
end
