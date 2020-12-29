defmodule Prometheus.Metric do
  @moduledoc """

  Prometheus metrics shortcuts.

  Aliases and requires respective metric modules so they are
  accessible without `Prometheus.Metric` prefix.

  Allows to automatically setup metrics with
  `@<type>` attributes. Metrics will be declared in
  the `@on_load` callback. If the module already
  has `@on_load` callback, metrics will be declared
  if the callback returns `:ok`.

  Example:

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
      # credo:disable-for-next-line Credo.Check.Readability.SpaceAfterCommas
      alias Prometheus.Metric.{Boolean, Counter, Gauge, Histogram, Summary}
      # credo:disable-for-next-line Credo.Check.Readability.SpaceAfterCommas
      require Prometheus.Metric.{Boolean, Counter, Gauge, Histogram, Summary}
      require Prometheus.Error

      unquote_splicing(
        for metric <- @metrics do
          quote do
            Module.register_attribute(
              unquote(module_name),
              unquote(metric),
              accumulate: true
            )
          end
        end
      )

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    mod = env.module

    declarations =
      for metric <- @metrics, params <- Module.delete_attribute(mod, metric) do
        {metric, params}
      end

    quote do
      def __declare_prometheus_metrics__() do
        if List.keymember?(Application.started_applications(), :prometheus, 0) do
          unquote_splicing(Enum.map(declarations, &emit_create_metric/1))
          :ok
        else
          existing_metrics = Application.get_env(:prometheus, :default_metrics, [])

          defined_metrics = unquote(Enum.map(declarations, &emit_metric_tuple/1))

          Application.put_env(
            :prometheus,
            :default_metrics,
            defined_metrics ++ existing_metrics
          )

          :ok
        end
      end

      unquote(gen_on_load(env))
    end
  end

  defp gen_on_load(env) do
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

  defp emit_metric_tuple({metric, params}) do
    quote do
      {unquote(metric), unquote(params)}
    end
  end

  defp emit_create_metric({metric, params}) do
    emit_create_metric(metric, params)
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
