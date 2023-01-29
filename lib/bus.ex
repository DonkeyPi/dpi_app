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

  # to be used from shell
  # Bus.monitor(:scanner)
  def monitor(event) do
    pid = spawn_link(fn -> monitor_init(event) end)
    IO.read(:line)
    :ok = monitor_done(pid)
  end

  defp monitor_init(event) do
    register!(event)
    monitor_loop(event)
  end

  defp monitor_loop(event) do
    self_pid = self()

    receive do
      {^self_pid, pid, :done} ->
        send(pid, {pid, self(), :done})

      {:event, {^event, _, dargs}} ->
        IO.puts("#{inspect({event, dargs})}")
        monitor_loop(event)
    end
  end

  defp monitor_done(pid) do
    send(pid, {pid, self(), :done})
    self_pid = self()

    receive do
      {^self_pid, ^pid, :done} -> :ok
    end
  end
end
