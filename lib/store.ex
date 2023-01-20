defmodule Dpi.App.Store do
  alias Dpi.App.Nerves
  use Agent

  def start_link(opts) do
    Agent.start_link(
      fn ->
        delay = Keyword.get(opts, :delay, 0)
        if delay > 0, do: :timer.sleep(delay)
        load()
      end,
      name: __MODULE__
    )
  end

  def drop(key) do
    key = string(key)

    Agent.update(__MODULE__, fn map ->
      delete(key)
      Map.delete(map, key)
    end)
  end

  def put(key, value) do
    key = string(key)

    Agent.update(__MODULE__, fn map ->
      save(key, value)
      Map.put(map, key, value)
    end)
  end

  def get(key, value \\ nil) do
    key = string(key)

    Agent.get_and_update(__MODULE__, fn map ->
      case value do
        nil ->
          {Map.get(map, key), map}

        _ ->
          case Map.get(map, key) do
            nil ->
              value = eval(value)
              save(key, value)
              {value, Map.put(map, key, value)}

            value ->
              {value, map}
          end
      end
    end)
  end

  def get(), do: Agent.get(__MODULE__, & &1)

  defp eval(value) when is_function(value, 0), do: value.()
  defp eval(value), do: value

  defp load() do
    File.mkdir_p!(path())

    for file <- Path.wildcard(Path.join(path(), "*.store")) do
      key = Path.basename(file) |> String.replace_suffix(".store", "")
      {key, File.read!(file)}
    end
    |> Enum.into(%{})
  end

  defp save(key, value) do
    File.write!(path(key), value)
    Nerves.sync!()
  end

  # Composite keys complicate loading
  defp string(key) when is_binary(key), do: key
  defp string(key) when is_atom(key), do: Atom.to_string(key)
  defp delete(key), do: File.rm!(path(key))
  defp path(key), do: Path.join(path(), "#{key}.store")
  defp path(), do: Path.join(Dpi.App.data(), "store")
end
