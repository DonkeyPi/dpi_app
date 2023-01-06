defmodule Dpi.App.Imports do
  def exit() do
    Process.exit(Process.group_leader(), :kill)
  end
end
