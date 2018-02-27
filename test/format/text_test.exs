defmodule Prometheus.Format.TextTest do
  use Prometheus.Case

  require Prometheus.Format.Text

  test "content_type" do
    assert "text/plain; version=0.0.4" == Prometheus.Format.Text.content_type()
  end

  test "gauge" do
    Gauge.new(name: :pool_size, help: "MongoDB Connections pool size")
    Gauge.set([name: :pool_size], 365)

    assert ~s"""
           # TYPE pool_size gauge
           # HELP pool_size MongoDB Connections pool size
           pool_size 365

           """ == Prometheus.Format.Text.format()
  end

  test "counter" do
    Counter.new(name: :http_requests_total, help: "Http request count")
    Counter.inc(name: :http_requests_total)

    assert ~s"""
           # TYPE http_requests_total counter
           # HELP http_requests_total Http request count
           http_requests_total 1

           """ == Prometheus.Format.Text.format()
  end

  test "dcounter" do
    Counter.new(name: :dtest, help: "qw\"\\e")
    Counter.inc([name: :dtest], 1.5)
    Counter.inc([name: :dtest], 3.5)
    Counter.inc([name: :dtest], 1.5)

    assert ~s"""
           # TYPE dtest counter
           # HELP dtest qw\"\\\\e
           dtest 6.5

           """ == Prometheus.Format.Text.format()
  end

  test "summary" do
    Summary.new(name: :orders_summary, help: "Track orders count/total sum")
    Summary.observe([name: :orders_summary], 10)
    Summary.observe([name: :orders_summary], 15)
    Summary.observe([name: :orders_summary], 1.5)
    Summary.observe([name: :orders_summary], 2.7)

    assert ~s"""
           # TYPE orders_summary summary
           # HELP orders_summary Track orders count/total sum
           orders_summary_count 4
           orders_summary_sum 29.2

           """ == Prometheus.Format.Text.format()
  end

  test "histogram" do
    Histogram.new(
      name: :http_request_duration_milliseconds,
      labels: [:method],
      buckets: [100, 300, 500, 750, 1000],
      help: "Http Request execution time",
      duration_unit: false
    )

    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 95)
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 100)
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 102)
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 150)
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 250)
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 75)
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 350)
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 550)
    Histogram.observe([name: :http_request_duration_milliseconds, labels: [:get]], 950)

    assert ~s"""
           # TYPE http_request_duration_milliseconds histogram
           # HELP http_request_duration_milliseconds Http Request execution time
           http_request_duration_milliseconds_bucket{method="get",le="100"} 3
           http_request_duration_milliseconds_bucket{method="get",le="300"} 6
           http_request_duration_milliseconds_bucket{method="get",le="500"} 7
           http_request_duration_milliseconds_bucket{method="get",le="750"} 8
           http_request_duration_milliseconds_bucket{method="get",le="1000"} 9
           http_request_duration_milliseconds_bucket{method="get",le="+Inf"} 9
           http_request_duration_milliseconds_count{method="get"} 9
           http_request_duration_milliseconds_sum{method="get"} 2622

           """ == Prometheus.Format.Text.format()
  end

  test "dhistogram" do
    Histogram.new(
      name: :http_request_duration_milliseconds,
      labels: [:method],
      buckets: [100, 300, 500, 750, 1000],
      help: "Http Request execution time",
      duration_unit: false
    )

    Histogram.observe(
      [name: :http_request_duration_milliseconds, labels: [:post]],
      500.2
    )

    Histogram.observe(
      [name: :http_request_duration_milliseconds, labels: [:post]],
      150.4
    )

    Histogram.observe(
      [name: :http_request_duration_milliseconds, labels: [:post]],
      450.5
    )

    Histogram.observe(
      [name: :http_request_duration_milliseconds, labels: [:post]],
      850.3
    )

    Histogram.observe(
      [name: :http_request_duration_milliseconds, labels: [:post]],
      750.9
    )

    Histogram.observe(
      [name: :http_request_duration_milliseconds, labels: [:post]],
      1650.23
    )

    assert ~s"""
           # TYPE http_request_duration_milliseconds histogram
           # HELP http_request_duration_milliseconds Http Request execution time
           http_request_duration_milliseconds_bucket{method=\"post\",le=\"100\"} 0
           http_request_duration_milliseconds_bucket{method=\"post\",le=\"300\"} 1
           http_request_duration_milliseconds_bucket{method=\"post\",le=\"500\"} 2
           http_request_duration_milliseconds_bucket{method=\"post\",le=\"750\"} 3
           http_request_duration_milliseconds_bucket{method=\"post\",le=\"1000\"} 5
           http_request_duration_milliseconds_bucket{method=\"post\",le=\"+Inf\"} 6
           http_request_duration_milliseconds_count{method=\"post\"} 6
           http_request_duration_milliseconds_sum{method=\"post\"} 4352.53

           """ == Prometheus.Format.Text.format()
  end
end
