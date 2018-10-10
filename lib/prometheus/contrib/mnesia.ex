defmodule Prometheus.Contrib.Mnesia do
  @moduledoc """
  Mnesia instrumentation helpers.
  """
  use Prometheus.Erlang, :prometheus_mnesia

  @doc """
  Returns sum of all mnesia files for the given `table` in bytes.
  Mnesia can create different files for each table:
  - .DAT - DETS files
  - .TMP - temp files
  - .DMP - dumped ets tables
  - .DCD - disc copies data
  - .DCL - disc copies log
  - .LOGTMP - disc copies log

  More on Mnesia files can be found in
  <a href="http://erlang.org/doc/apps/mnesia/Mnesia_chap7.html">
  Mnesia System Information chapter
  </a> of Mnesia User's Guide
  """
  delegate table_disk_size(dir \\ :mnesia.system_info(:directory), table)

  @doc """
  Returns {pcount, ccount} tuple, where
  pcount is a number of participant transactions and
  ccount is a number of coordinator transactions.
  Can return {:undefined, :undefined} occasionally.
  """
  delegate tm_info()
end
