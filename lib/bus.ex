defmodule Dpi.App.Bus do
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
    Registry.start_link(keys: :duplicate, name: __MODULE__)
  end

  def register!(event, rargs \\ nil) do
    case register(event, rargs) do
      {:ok, _} -> :ok
      {:error, reason} -> raise("error #{inspect(reason)}")
    end
  end

  def dispatch!(event, dargs \\ nil) do
    :ok = dispatch(event, dargs)
  end

  defp register(event, rargs) do
    Registry.register(__MODULE__, event, rargs)
  end

  defp dispatch(event, dargs) do
    Registry.dispatch(__MODULE__, event, fn entries ->
      for {pid, rargs} <- entries, do: send(pid, {:event, {event, rargs, dargs}})
    end)
  end
end
