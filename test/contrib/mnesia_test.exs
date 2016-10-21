defmodule Prometheus.Contrib.MnesiaTest do
  use ExUnit.Case

  use Prometheus

  test "table disk size" do
    {:ok, root} = :file.get_cwd()
    mnesia_dir = root ++ '/test/mnesia'
    set_custom_mnesia_dir(mnesia_dir)

    assert mnesia_dir == :mnesia.system_info(:directory)

    assert 3 = Prometheus.Contrib.Mnesia.table_disk_size(mnesia_dir, :table)
    assert 21 = Prometheus.Contrib.Mnesia.table_disk_size(:my_table)
  end

  test "tm info test" do
    try do
      :mnesia.start()
      assert {_, _} = Prometheus.Contrib.Mnesia.tm_info()
    after
      :mnesia.stop()
    end
  end

  defp set_custom_mnesia_dir(dir) do
    try do
      :ets.lookup_element(:mnesia_gvar, :dir, 2)
      :ets.update_element(:mnesia_gvar, :dir, dir)
    rescue
      ArgumentError ->
        :application.set_env(:mnesia, :dir, dir)
    end
  end

end
