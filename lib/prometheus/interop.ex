defmodule Prometheus.Erlang do

  require Prometheus.Metric
  alias Prometheus.Metric

  def new(m, spec) do
    ctor(m, :new, spec)
  end

  def declare(m, spec) do
    ctor(m, :declare, spec)
  end

  defp ctor(m, f, spec) do
    quote do
      require Prometheus.Error
      Prometheus.Error.with_prometheus_error(
        unquote(m).unquote(f)(unquote(spec))
      )
    end
  end

  def call(mfa, arguments \\ []) do
    {module, function} = mfa
    
    quote do

      require Prometheus.Error

      Prometheus.Error.with_prometheus_error(
        unquote(module).unquote(function)(unquote_splicing(arguments)))

    end
  end

  def metric_call(mfa, spec, arguments \\ []) do
    {module, function} = mfa

    case spec do
      _ when Metric.ct_parsable_spec?(spec) ->

        {registry, name, labels} = Metric.parse_spec(spec)

        quote do

          require Prometheus.Error

          Prometheus.Error.with_prometheus_error(
            unquote(module).unquote(function)(unquote(registry), unquote(name), unquote(labels),
              unquote_splicing(arguments)))

        end
      _ ->
        quote do

          require Prometheus.Error

          {registry, name, labels} = Metric.parse_spec(unquote(spec))

          Prometheus.Error.with_prometheus_error(
            unquote(module).unquote(function)(registry, name, labels,
              unquote_splicing(arguments)))

        end
    end
  end

end
