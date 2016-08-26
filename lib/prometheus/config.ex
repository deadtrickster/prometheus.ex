defmodule Prometheus.Config do
  defmacro __using__(default_config) do

    quote do
      defmodule Config do
        @moduledoc false

        def config(key) do
          Application.get_env(:prometheus, key, unquote(default_config))
        end

        defp config(key, name, default) do
          config(key)
          |> Keyword.get(name, default)
        end

        unquote do
          for {option, default} <- default_config do
            quote do
              def unquote(option)(key) do
                config(key, unquote(option), unquote(default))
              end
            end
          end
        end
      end
    end
  end
end
