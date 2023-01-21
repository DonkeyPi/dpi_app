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

  def read_authorized_keys() do
    if on() do
      File.read!("/data/nerves_ssh/default_user/authorized_keys")
    end
  end

  # Confirmed file recreated on reboot (to remove spurious keys)
  def rm_authorized() do
    if on() do
      File.rm("/data/nerves_ssh/default_user/authorized_keys")
    end
  end

  def add_pubkey(pubkey) do
    :rpc.call(:dpi@localhost, NervesSSH, :add_authorized_key, [pubkey])
  end

  def remove_pubkey(pubkey) do
    :rpc.call(:dpi@localhost, NervesSSH, :remove_authorized_key, [pubkey])
  end
end
