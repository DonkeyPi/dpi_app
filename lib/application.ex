defmodule Dpi.App.Application do
  use Application
  require Dpi.App

  def start(_type, _args) do
    Calendar.put_time_zone_database(Zoneinfo.TimeZoneDatabase)

    try do
      setup()
    rescue
      e ->
        Dpi.App.log("#{inspect(e)}")
        System.stop(1)
    end
  end

  def setup() do
    case Dpi.App.in_rt() do
      true ->
        remote = Dpi.App.node_remote()
        local = Dpi.App.node_name()
        cookie = Dpi.App.cookie()
        {:ok, _} = Node.start(local, :shortnames)
        true = Node.set_cookie(cookie)
        true = Node.connect(remote)
        children = [{Dpi.App.Monitor, []}]
        Supervisor.start_link(children, strategy: :one_for_one)

      _ ->
        Supervisor.start_link([], strategy: :one_for_one)
    end
  end
end
