defmodule Ash.App do
  def in_rt(), do: System.get_env("ASH_RT") != nil
  def node_remote(), do: System.get_env("ASH_NODE") |> String.to_atom()
  def node_name(), do: System.get_env("ASH_NAME") |> String.to_atom()
  def app_name(), do: System.get_env("ASH_APP") |> String.to_atom()
  def cookie(), do: System.get_env("ASH_COOKIE") |> String.to_atom()

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
