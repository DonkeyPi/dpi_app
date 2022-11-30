defmodule Ash.App.Shell do
  require Ash.App

  # applications can override .iex file
  def start(opts, mfa) do
    path =
      with true <- Ash.App.in_rt(),
           path <-
             Ash.App.app_name()
             |> :code.priv_dir()
             |> :filename.join(".iex.exs"),
           true <- File.regular?(path) do
        path
      else
        _ ->
          :code.priv_dir(:ash_app)
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
