defmodule Prometheus.Config do
  @moduledoc """

  Configuration templates for custom collectors/exporters.

  When `use`ed, generates accessor for each configuration option:

      iex(4)> defmodule MyInstrumenter do
      ...(4)>   use Prometheus.Config, [:required_option,
      ...(4)>                           registry: :default]
      ...(4)> end
      iex(5)> MyInstrumenter.Config.registry(MyInstrumenter)
      :default
      iex(6)> MyInstrumenter.Config.required_option!(MyInstrumenter)
      ** (Prometheus.Config.KeyNotFoundError) mandatory option :required_option not found in PrometheusTest.MyInstrumenter instrumenter/collector config
      iex(7)> Application.put_env(:prometheus, MyInstrumenter,
      ...(7)>                     [required_option: "Hello world!"])
      :ok
      iex(8)> MyInstrumenter.Config.required_option!(MyInstrumenter)
      "Hello world!"

  """

  defmodule KeyNotFoundError do
    @moduledoc """
    Raised when mandatory configuration option not found in app env.
    """
    defexception [:option, :key]

    def message(%{option: option, key: key}) do
      friendly_key_name = String.replace_leading("#{key}", "Elixir.", "")

      "mandatory option :#{option} not found" <>
        " in #{friendly_key_name} instrumenter/collector config"
    end
  end

  defmacro __using__(default_config) do
    keyword_default_config =
      Enum.reject(default_config, fn option ->
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
          key
          |> config()
          |> Keyword.get(option, default)
        end

        defp config(key, option) do
          key
          |> config()
          |> Keyword.fetch!(option)
        rescue
          e in KeyError ->
            # credo:disable-for-next-line Credo.Check.Warning.RaiseInsideRescue
            raise %KeyNotFoundError{key: key, option: option}
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
