defmodule App do
  use Application

  def start(_type, _args) do
    case System.get_env("ASH_RT") do
      nil ->
        Supervisor.start_link([], strategy: :one_for_one)

      _ ->
        app_name = System.get_env("ASH_APP") |> String.to_atom()
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

  defmacro log(msg) do
    # remove Elixir from begining of name
    module = __CALLER__.module |> Atom.to_string() |> String.slice(7, 9999)

    quote do
      msg = unquote(msg)
      module = unquote(module)
      # 2022-09-10 20:02:49.684244Z
      now = DateTime.utc_now()
      now = String.slice("#{now}", 11..22)
      IO.puts("#{now} #{inspect(self())} #{module} #{msg}")
    end
  end
end
