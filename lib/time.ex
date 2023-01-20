defmodule Dpi.App.Time do
  def set_time(ndt) do
    :rpc.call(:dpi@localhost, NervesTime.SystemTime, :set_time, [ndt])
  end

  def set_timezone(zone) do
    :rpc.call(:dpi_console@localhost, Dpi.Console.Store, :put, [:timezone, zone])
  end
end
