defmodule App.Shell do
  def shell(opts, mfa) do
    path =
      :code.priv_dir(:app)
      |> :filename.join(".iex.exs")

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
