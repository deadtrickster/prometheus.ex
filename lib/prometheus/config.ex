defmodule Prometheus.Config do
  defmacro __using__(default_config) do
    target_module = __CALLER__.module

    quote do
      defmodule Config do
        def config do
          Application.get_env(:prometheus, unquote(prometheus_env_key(target_module)), unquote(default_config))
        end

        defp config(name, default) do
          config
          |> Keyword.get(name, default)
        end

        unquote do
          for {option, default} <- default_config do
            quote do
              def unquote(option)() do
                config(unquote(option), unquote(default))
              end
            end
          end
        end
      end
    end
  end

  defp prometheus_env_key (target_module) do
    integration_name_string = target_module
    |> Atom.to_string
    |> String.split(".")
    |> Enum.at(2)

    String.to_atom("Elixir." <> integration_name_string)
  end
end
