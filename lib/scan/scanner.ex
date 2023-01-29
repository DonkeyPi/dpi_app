defmodule Dpi.App.Scanner do
  alias Dpi.App.State
  alias Dpi.App.Bus

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      restart: :permanent,
      type: :worker,
      shutdown: 500
    }
  end

  # ensure scanner appends \n = 0x0A suffix
  @opts [:binary, packet: :line, active: true]
  @event :scanner
  @openms 1000
  @toms 2000
  @keepalive "\x00"

  def start_link(opts) do
    {:ok, spawn_link(fn -> init(opts) end)}
  end

  def init(opts) do
    delay = Keyword.get(opts, :delay, 0)
    if delay > 0, do: :timer.sleep(delay)
    port = Keyword.fetch!(opts, :port)
    event = Keyword.get(opts, :event, @event)
    ip = Keyword.get(opts, :ip, "127.0.0.1")
    ip = ip |> String.to_charlist()
    State.put(:opts, %{event: event, ip: ip, port: port})
    connect()
  end

  defp connect() do
    %{port: port, event: event, ip: ip} = State.get(:opts)

    case :gen_tcp.connect(ip, port, @opts, @toms) do
      {:ok, socket} ->
        # check alive to avoid sending a disconnected just after a connected
        case {:gen_tcp.send(socket, @keepalive), alive?(socket)} do
          {:ok, true} ->
            Bus.dispatch!(event, {:status, :connected})
            loop(socket)

          _ ->
            Bus.dispatch!(event, {:status, :disconnected})
            Process.sleep(@toms)
            connect()
        end

      _ ->
        Bus.dispatch!(event, {:status, :disconnected})
        Process.sleep(@toms)
        connect()
    end
  end

  defp loop(socket) do
    %{event: event} = State.get(:opts)

    receive do
      {:tcp, ^socket, data} ->
        Bus.dispatch!(event, {:scan, String.trim(data)})
        loop(socket)

      {:tcp_closed, ^socket} ->
        Bus.dispatch!(event, {:status, :disconnected})
        # honewell scanner takes 8s to reconnect
        # without this sleep it takes forever
        Process.sleep(@toms)
        connect()
    after
      @toms ->
        :gen_tcp.send(socket, @keepalive)
        loop(socket)
    end
  end

  defp alive?(socket) do
    receive do
      {:tcp_closed, ^socket} -> false
    after
      @openms -> true
    end
  end
end
