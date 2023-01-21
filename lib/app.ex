defmodule Dpi.App do
  def in_rt(), do: System.get_env("DPI_RT") == "true"
  def in_nerves(), do: System.get_env("DPI_NERVES") == "true"
  def node_remote(), do: System.get_env("DPI_NODE") |> String.to_atom()
  def node_name(), do: System.get_env("DPI_NAME") |> String.to_atom()
  def app_name(), do: System.get_env("DPI_APP") |> String.to_atom()
  def cookie(), do: System.get_env("DPI_COOKIE") |> String.to_atom()
  def data(), do: path() |> String.replace_suffix(".lib", ".data")
  def path(), do: System.get_env("DPI_PATH")

  # called from Application entry points only
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
