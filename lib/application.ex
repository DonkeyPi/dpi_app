defmodule App.Application do
  use Application
  require App

  def start(_type, _args) do
    try do
      setup()
    rescue
      e ->
        App.log("#{inspect(e)}")
        System.stop(1)
    end
  end

  def setup() do
    case System.get_env("ASH_RT") do
      nil ->
        Supervisor.start_link([], strategy: :one_for_one)

      _ ->
        node = System.get_env("ASH_NODE") |> String.to_atom()
        name = System.get_env("ASH_NAME") |> String.to_atom()
        cookie = System.get_env("ASH_COOKIE") |> String.to_atom()
        {:ok, _} = Node.start(:"#{name}", :shortnames)
        true = Node.set_cookie(cookie)
        true = Node.connect(node)
        children = [{App.Monitor, []}]
        Supervisor.start_link(children, strategy: :one_for_one)
    end
  end
end
