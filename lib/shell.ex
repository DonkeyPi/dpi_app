defmodule Ash.App.Shell do
  # applications can override .iex file
  def start(opts, mfa) do
    path =
      case System.get_env("ASH_NAME") do
        nil ->
          :code.priv_dir(:ash_app)
          |> :filename.join(".iex.exs")

        name ->
          name
          |> String.to_atom()
          |> :code.priv_dir()
          |> :filename.join(".iex.exs")
      end

    opts = Keyword.put(opts, :dot_iex_path, path)
    IEx.start(opts, mfa)
  end

  def capture_eval(code) do
    try do
      Code.eval_string(code)
    rescue
      e -> {e, __STACKTRACE__}
    end
  end
end
