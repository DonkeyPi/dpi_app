defmodule Ash.App.Application do
  use Application
  require Ash.App

  def start(_type, _args) do
    Calendar.put_time_zone_database(Zoneinfo.TimeZoneDatabase)

    try do
      setup()
    rescue
      e ->
        Ash.App.log("#{inspect(e)}")
        System.stop(1)
    end
  end

  def setup() do
    case Ash.App.in_rt() do
      true ->
        remote = Ash.App.node_remote()
        local = Ash.App.node_name()
        cookie = Ash.App.cookie()
        {:ok, _} = Node.start(local, :shortnames)
        true = Node.set_cookie(cookie)
        true = Node.connect(remote)
        children = [{Ash.App.Monitor, []}]
        Supervisor.start_link(children, strategy: :one_for_one)

      _ ->
        Supervisor.start_link([], strategy: :one_for_one)
    end
  end
end
