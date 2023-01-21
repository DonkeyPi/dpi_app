defmodule Dpi.App.Nerves do
  def on(), do: Dpi.App.in_nerves()

  def sync!() do
    if on() do
      :rpc.call(:dpi@localhost, Dpi.Native, :sync!, [])
    end
  end

  def sync() do
    if on() do
      :rpc.call(:dpi@localhost, Dpi.Native, :sync, [])
    end
  end

  def reboot() do
    if on() do
      :rpc.call(:dpi@localhost, Nerves.Runtime, :reboot, [])
    end
  end

  def poweroff() do
    if on() do
      :rpc.call(:dpi@localhost, Nerves.Runtime, :poweroff, [])
    end
  end

  def boardid() do
    if on() do
      {boardid, 0} = System.cmd("boardid", ["-b", "rpi", "-n", "8"])
      "dpi-#{boardid |> String.trim()}"
    else
      {:ok, hostname} = :inet.gethostname()
      hostname
    end
  end

  def set_time(naive) do
    :rpc.call(:dpi@localhost, NervesTime.SystemTime, :set_time, [naive])
  end
end
