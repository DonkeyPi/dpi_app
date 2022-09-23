defmodule App.Application do
  use Application

  def start(_type, _args) do
    case System.get_env("ASH_RT") do
      nil ->
        Supervisor.start_link([], strategy: :one_for_one)

      _ ->
        node = System.get_env("ASH_NODE") |> String.to_atom()
        name = System.get_env("ASH_NAME") |> String.to_atom()
        cookie = System.get_env("ASH_COOKIE") |> String.to_atom()
        {:ok, _} = Node.start(:"#{name}")
        true = Node.set_cookie(cookie)
        true = Node.connect(node)
        children = [{App.Monitor, []}]
        Supervisor.start_link(children, strategy: :one_for_one)
    end
  end
end
