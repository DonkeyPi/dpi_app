defmodule Dpi.App.UsbDisk do
  alias Dpi.App.Nerves
  @disks "/data/disks"

  def root(), do: @disks

  def list(), do: list(Nerves.on())
  def list(false), do: []

  def list(true) do
    "#{@disks}/Usb_*"
    |> Path.wildcard()
    |> Enum.map(&Path.basename/1)
  end
end
