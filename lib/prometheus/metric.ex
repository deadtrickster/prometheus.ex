defmodule Prometheus.Metric do
  @moduledoc """

  Prometheus metrics shortcuts.

  Aliases and requires respective metric modules so they are
  accessible without `Prometheus.Metric` prefix.

  Allows to automatically setup metrics with
  `@<type`> attributes. Metrics will be declared in
  the `@on_load` callback. If the module already
  has `@on_laod` callback, metrics will be declared
  iff the callback returns `:ok`.

     iex(1)> defmodule MyCoolModule do
     ...(1)>   use Prometheus.Metric
     ...(1)>
     ...(1)>   @counter name: :test_counter3, labels: [], help: "qwe"
     ...(1)> end
     iex(2)> require Prometheus.Metric.Counter
     Prometheus.Metric.Counter
     iex(3)> Prometheus.Metric.Counter.value(:test_counter3)
     0

  """

  @metrics [:counter, :gauge, :boolean, :summary, :histogram]

  defmacro __using__(_opts) do
    module_name = __CALLER__.module

    quote do
      alias Prometheus.Metric.{Counter,Gauge,Histogram,Summary,Boolean}
      require Prometheus.Metric.{Counter,Gauge,Histogram,Summary,Boolean}
      require Prometheus.Error

      unquote_splicing(
        for metric <- @metrics do
          quote do
            Module.register_attribute unquote(module_name), unquote(metric), accumulate: true
          end
        end)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    quote do
      def __declare_prometheus_metrics__() do
        if List.keymember?(Application.started_applications(), :prometheus, 0) do
          unquote_splicing(
            for metric <- @metrics do
              declarations = Module.get_attribute(env.module, metric)
              Module.delete_attribute(env.module, metric)
              quote do
                unquote_splicing(
                  for params <- declarations do
                    emit_create_metric(metric, params)
                  end)
                :ok
              end
            end)
        else
          :ok
        end
      end

      unquote(
        case get_on_load_attribute(env.module) do
          nil ->
            quote do
              @on_load :__declare_prometheus_metrics__
            end
          on_load ->
            Module.delete_attribute(env.module, :on_load)
            Module.put_attribute(env.module, :on_load, :__prometheus_on_load_override__)
            quote do
              def __prometheus_on_load_override__() do
                case unquote(on_load)() do
                  :ok -> __declare_prometheus_metrics__()
                  result -> result
                end
              end
            end
        end)
    end
  end

  defp get_on_load_attribute(module) do
    case Module.get_attribute(module, :on_load) do
      [] ->
        nil
      nil ->
        nil
      atom when is_atom(atom) ->
        atom
      {atom, 0} when is_atom(atom) ->
        atom
      [{atom, 0}] when is_atom(atom) ->
        atom
      other ->
        raise ArgumentError,
          "expected the @on_load attribute to be an atom or a " <>
          "{atom, 0} tuple, got: #{inspect(other)}"
    end
  end

  defp emit_create_metric(:counter, params) do
    quote do
      Prometheus.Metric.Counter.declare(unquote(params))
    end
  end
  defp emit_create_metric(:gauge, params) do
    quote do
      Prometheus.Metric.Gauge.declare(unquote(params))
    end
  end
  defp emit_create_metric(:boolean, params) do
    quote do
      Prometheus.Metric.Boolean.declare(unquote(params))
    end
  end
  defp emit_create_metric(:summary, params) do
    quote do
      Prometheus.Metric.Summary.declare(unquote(params))
    end
  end
  defp emit_create_metric(:histogram, params) do
    quote do
      Prometheus.Metric.Histogram.declare(unquote(params))
    end
  end

  defmacro ct_parsable_spec?(spec) do
    quote do
      is_list(unquote(spec)) or is_atom(unquote(spec))
    end
  end

  def parse_spec(spec) when is_list(spec) do
    registry = Keyword.get(spec, :registry, :default)
    name = Keyword.fetch!(spec, :name)
    labels = Keyword.get(spec, :labels, [])
    {registry, name, labels}
  end
  def parse_spec(spec) when is_atom(spec) do
    {:default, spec, []}
  end

end
