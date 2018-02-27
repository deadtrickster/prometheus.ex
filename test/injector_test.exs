defmodule Injector do
  defmacro test(ast) do
    Prometheus.Injector.inject(
      fn block ->
        quote do
          try do
            IO.puts("before block")
            unquote(block)
          after
            IO.puts("after block")
          end
        end
      end,
      __CALLER__,
      ast
    )
  end
end

defmodule Prometheus.InjectorTest do
  use Prometheus.Case

  require Injector

  Injector.test do
    def fun1() do
      IO.puts("fun1")
    end

    def fun2() do
      IO.puts("fun2")
    end

    Injector.test do
      def fun3() do
        IO.puts("fun3")
      rescue
        e in RuntimeError ->
          IO.puts(e)
      end
    end
  end

  def do_dangerous_work(x) do
    Injector.test do
      IO.puts("Doing dangerous work #{x}")
    rescue
      _ -> IO.puts("Died")
    after
      IO.puts("Done anyway")
    end
  end

  test "fn" do
    assert capture_io(fn ->
             Injector.test(fn -> IO.puts("qwe") end)
           end) == "before block\nqwe\nafter block\n"
  end

  test "blocks" do
    assert capture_io(fn ->
             Injector.test(IO.puts("qwe"))
           end) == "before block\nqwe\nafter block\n"

    assert capture_io(fn ->
             Injector.test(do: IO.puts("qwe"))
           end) == "before block\nqwe\nafter block\n"

    assert capture_io(fn ->
             Injector.test do
               IO.puts("qwe")
               IO.puts("qwa")
             end
           end) == "before block\nqwe\nqwa\nafter block\n"
  end

  test "implicit try" do
    assert capture_io(fn ->
             do_dangerous_work(5)
           end) == "before block\nDoing dangerous work 5\nDone anyway\nafter block\n"

    assert capture_io(fn ->
             do_dangerous_work({})
           end) == "before block\nDied\nDone anyway\nafter block\n"
  end

  test "defs" do
    assert capture_io(fn ->
             fun1()
           end) == "before block\nfun1\nafter block\n"

    assert capture_io(fn ->
             fun2()
           end) == "before block\nfun2\nafter block\n"

    assert capture_io(fn ->
             fun3()
           end) == "before block\nbefore block\nfun3\nafter block\nafter block\n"
  end

  defmodule QweInjector do
    defmacro inject_(body) do
      Prometheus.Injector.inject_(body, fn b ->
        quote do
          IO.puts("qwe")

          try do
            unquote(b)
          after
            IO.puts("after_qwe")
          end
        end
      end)
    end

    defmacro inject1(body) do
      body
    end
  end

  defmodule UsefulModule do
    require QweInjector

    def do_work(x) do
      QweInjector.inject_ do
        IO.puts("Doing work #{inspect(x)}")
      end
    end

    def do_dangerous_work(x) do
      QweInjector.inject_ do
        IO.puts("Doing dangerous work #{x}")
      rescue
        _ -> IO.puts("Died")
      after
        IO.puts("Done anyway")
      end
    end

    QweInjector.inject_ do
      def mildly_interesting(what) do
        IO.puts("#{what} is mildly interesting")
      end

      def wtf(what) do
        IO.puts("#{what} is wtf")
      rescue
        _ -> IO.puts("Oh my, #{inspect(what)} is real wtf")
      else
        _ -> IO.puts("Saw wtf and still stronk")
      end
    end
  end

  test "UsefulModule" do
    assert capture_io(fn ->
             UsefulModule.wtf({})
           end) == "qwe\nOh my, {} is real wtf\nafter_qwe\n"
  end
end
