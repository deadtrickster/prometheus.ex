defmodule Prometheus.Injector do
  def inject(callback, env, ast) do
    ast
    |> Macro.prewalk(fn thing ->
      case thing do
        {:def, _, _} = defun ->
          defun

        # otherwise e in RuntimeError will be rewritten
        {:in, _, _} = arrow ->
          arrow

        _ ->
          Macro.expand(thing, env)
      end
    end)
    |> inject_(callback)
  end

  # lambda
  def inject_({:fn, fn_meta, [{:->, arrow_meta, [args, do_block]}]}, callback) do
    case args do
      [] ->
        callback.(
          {{:., [], [{:fn, fn_meta, [{:->, arrow_meta, [[], do_block]}]}]}, [], []}
        )

      _ ->
        names =
          args
          |> Enum.map(fn {name, _, _} -> name end)

        raise Prometheus.InvalidBlockArityError, args: names
    end
  end

  # do_blocks can be simple calls or defs
  def inject_([{:do, {:__block__, [], do_blocks}}], callback) do
    do_blocks = List.flatten(do_blocks)

    if have_defs(do_blocks) do
      Enum.map(do_blocks, &inject_to_def(&1, callback))
    else
      callback.({:__block__, [], do_blocks})
    end
  end

  # just do
  def inject_([{:do, do_block}], callback) do
    inject_([{:do, {:__block__, [], [do_block]}}], callback)
  end

  # implicit try
  def inject_([{:do, _do_block} | rest] = all, callback) do
    if is_try_unwrapped(rest) do
      callback.(
        quote do
          try unquote(all)
        end
      )
    else
      raise "Unexpected do block #{inspect(rest)}"
    end
  end

  # single do, or other non-block stuff like function calls
  def inject_(thing, callback) do
    inject_([{:do, {:__block__, [], [thing]}}], callback)
  end

  defp is_try_unwrapped(block) do
    Keyword.has_key?(block, :catch) || Keyword.has_key?(block, :rescue) ||
      Keyword.has_key?(block, :after) || Keyword.has_key?(block, :else)
  end

  defp have_defs(blocks) do
    defs_count =
      Enum.count(blocks, fn
        {:def, _, _} -> true
        _ -> false
      end)

    blocks_count = Enum.count(blocks)

    case defs_count do
      0 -> false
      ^blocks_count -> true
      _ -> raise "Mixing defs and other blocks isn't allowed"
    end
  end

  defp inject_to_def({:def, def_meta, [head, [do: body]]}, callback) do
    {:def, def_meta, [head, [do: callback.(body)]]}
  end

  defp inject_to_def({:def, def_meta, [head, [{:do, _do_block} | _rest] = all]}, callback) do
    {:def, def_meta,
     [
       head,
       [
         do:
           callback.(
             quote do
               try unquote(all)
             end
           )
       ]
     ]}
  end
end
