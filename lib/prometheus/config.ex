defmodule Prometheus.Config do

  defmodule KeyNotFoundError do
    defexception [:option, :key]

    def message(%{option: option, key: key}) do
      friendly_key_name = String.replace_leading("#{key}", "Elixir.", "")
      "mandatory option :#{option} not found in #{friendly_key_name} instrumenter/collector config"
    end
  end

  defmacro __using__(default_config) do

    keyword_default_config = Enum.reject(default_config, fn(option) ->
      case option do
        {_, _} -> false
        _ -> true
      end
    end)

    quote do
      defmodule Config do
        @moduledoc false

        def config(key) do
          Application.get_env(:prometheus, key, unquote(keyword_default_config))
        end

        defp config(key, option, default) do
          config(key)
          |> Keyword.get(option, default)
        end

        defp config(key, option) do
          try do
            config(key)
            |> Keyword.fetch!(option)
          rescue
            e in KeyError -> raise %KeyNotFoundError{key: key, option: option}
          end
        end

        unquote do
          for config <- default_config do
            case config do
              {option, default} ->
                quote do
                  def unquote(option)(key) do
                    config(key, unquote(option), unquote(default))
                  end
                end
              option ->
                quote do
                  def unquote(:"#{option}!")(key) do
                    config(key, unquote(option))
                  end
                end
            end
          end
        end
      end
    end
  end
end
