defmodule Prometheus.Erlang do
  @moduledoc false

  require Prometheus.Metric
  alias Prometheus.Metric

  defmacro __using__(erlang_module) do
    quote do
      @erlang_module unquote(erlang_module)

      require Prometheus.Error

      import unquote(__MODULE__)
    end
  end

  if Version.match?(System.version(), "< 1.14.0-rc.0") do
    def defdelegate_each(fun, opts), do: Kernel.Utils.defdelegate(fun, opts)
  else
    def defdelegate_each(fun, opts), do: Kernel.Utils.defdelegate_each(fun, opts)
  end

  defmacro delegate(fun, opts \\ []) do
    fun = Macro.escape(fun, unquote: true)

    quote bind_quoted: [fun: fun, opts: opts] do
      target = Keyword.get(opts, :to, @erlang_module)

      {name, args, as, as_args} = defdelegate_each(fun, opts)

      def unquote(name)(unquote_splicing(args)) do
        Prometheus.Error.with_prometheus_error(
          unquote(target).unquote(as)(unquote_splicing(as_args))
        )
      end
    end
  end

  defmacro delegate_metric(fun, opts \\ []) do
    fun = Macro.escape(fun, unquote: true)

    quote bind_quoted: [fun: fun, opts: opts] do
      target = Keyword.get(opts, :to, @erlang_module)

      {name, args, as, [spec | as_args]} = defdelegate_each(fun, opts)

      def unquote(name)(unquote_splicing(args)) do
        {registry, name, labels} = Metric.parse_spec(unquote(spec))

        Prometheus.Error.with_prometheus_error(
          unquote(target).unquote(as)(registry, name, labels, unquote_splicing(as_args))
        )
      end
    end
  end
end
