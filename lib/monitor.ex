defmodule Ash.App.Monitor do
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :permanent,
      type: :worker,
      shutdown: 500
    }
  end

  def start_link() do
    pid = spawn_link(&monitor/0)
    {:ok, pid}
  end

  defp monitor() do
    case IO.read(:line) do
      # :erlang.halt - sudden
      # :init.stop - orderly
      :eof -> :init.stop()
      _ -> monitor()
    end
  end
end
