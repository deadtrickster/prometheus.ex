defmodule Prometheus.Erlang do
  @moduledoc false

  require Prometheus.Metric
  alias Prometheus.Metric

  defmacro __using__(erlang_module) do
    quote do
      @erlang_module unquote(erlang_module)
      alias Prometheus.Erlang
    end
  end

  defmacro call(mf \\ false, arguments \\ []) do
    {module, function, arguments} = parse_mfa(__CALLER__, mf, arguments)

    quote do
      Prometheus.Erlang.call_body(unquote(module), unquote(function), unquote(arguments))
    end
  end

  def call_body(module, function, arguments) do
    quote do
      require Prometheus.Error

      Prometheus.Error.with_prometheus_error(
        unquote(module).unquote(function)(unquote_splicing(arguments))
      )
    end
  end

  defmacro metric_call(mf_or_spec, spec \\ false, arguments \\ []) do
    {mf, spec, arguments} = parse_metric_call_args(mf_or_spec, spec, arguments)

    {module, function, arguments} = parse_mfa(__CALLER__, mf, arguments)

    quote do
      Prometheus.Erlang.metric_call_body(
        unquote(module),
        unquote(function),
        unquote(spec),
        unquote(arguments)
      )
    end
  end

  def metric_call_body(module, function, spec, arguments) do
    case spec do
      _ when Metric.ct_parsable_spec?(spec) ->
        {registry, name, labels} = Prometheus.Metric.parse_spec(spec)

        quote do
          require Prometheus.Error

          Prometheus.Error.with_prometheus_error(
            unquote(module).unquote(function)(
              unquote(registry),
              unquote(name),
              unquote(labels),
              unquote_splicing(arguments)
            )
          )
        end

      _ ->
        quote do
          require Prometheus.Error

          {registry, name, labels} = Metric.parse_spec(unquote(spec))

          Prometheus.Error.with_prometheus_error(
            unquote(module).unquote(function)(
              registry,
              name,
              labels,
              unquote_splicing(arguments)
            )
          )
        end
    end
  end

  defp parse_metric_call_args(mf_or_spec, spec, arguments) do
    case mf_or_spec do
      ## Erlang.metric_call({:prometheus_counter, :dinc}, spec, [value])
      {_, _} ->
        {mf_or_spec, spec, arguments}

      ## Erlang.metric_call(:inc, spec, [value])
      _ when is_atom(mf_or_spec) ->
        {mf_or_spec, spec, arguments}

      _ ->
        ## args are 'shifted' to left
        [] = arguments

        if spec == false do
          ## only spec is needed, e.g. Erlang.metric_call(spec)
          {false, mf_or_spec, []}
        else
          ## Erlang.metric_call(spec, [value])
          {false, mf_or_spec, spec}
        end
    end
  end

  defp parse_mfa(caller, mf, arguments) do
    arguments =
      case mf do
        _ when is_list(mf) ->
          [] = arguments
          mf

        _ ->
          arguments
      end

    {module, function} =
      case mf do
        false ->
          {f, _arity} = caller.function
          {Module.get_attribute(caller.module, :erlang_module), f}

        _ when is_list(mf) ->
          {f, _arity} = caller.function
          {Module.get_attribute(caller.module, :erlang_module), f}

        {_, _} ->
          mf

        _ when is_atom(mf) ->
          {Module.get_attribute(caller.module, :erlang_module), mf}
      end

    {module, function, arguments}
  end

  def ensure_fn(var) do
    case var do
      [do: block] ->
        quote do
          fn ->
            unquote(block)
          end
        end

      fun ->
        quote do
          unquote(fun)
        end
    end
  end
end
