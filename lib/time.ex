defmodule Dpi.App.Time do
  alias Dpi.App.Store

  def load_timezone(), do: Store.get(:timezone, "CET")
  def save_timezone(zone), do: Store.put(:timezone, zone)

  def get_time(), do: DateTime.now!(load_timezone())
  def get_time(zone), do: DateTime.now!(zone)
end
