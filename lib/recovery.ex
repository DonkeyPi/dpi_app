defmodule Dpi.App.Recovery do
  alias Dpi.App.Nerves
  @keys "/data/keys"

  def list() do
    File.mkdir_p!(@keys)
    pattern = "#{@keys}/#{Nerves.boardid()}-*.pub"
    Path.wildcard(pattern) |> Enum.map(&Path.basename/1)
  end
end
