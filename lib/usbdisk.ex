defmodule Dpi.App.UsbDisk do
  @disks "/data/disks"

  def list() do
    "#{@disks}/Usb_*"
    |> Path.wildcard()
    |> Enum.map(&Path.basename/1)
  end
end
