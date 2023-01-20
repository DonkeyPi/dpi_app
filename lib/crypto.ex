defmodule Dpi.App.Crypto do
  def sha1(data) do
    :crypto.hash(:sha, data)
    |> Base.encode16()
    |> String.downcase()
  end
end
