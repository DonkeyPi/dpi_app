defmodule Dpi.App.State do
  def get(name, value \\ nil) do
    Process.get({__MODULE__, name}, value)
  end

  def put(name, value) do
    Process.put({__MODULE__, name}, value)
  end

  def delete(name) do
    Process.delete({__MODULE__, name})
  end

  def update(name, updater) do
    value = Process.get({__MODULE__, name})
    value = updater.(value)
    Process.put({__MODULE__, name}, value)
  end
end
