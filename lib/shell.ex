defmodule App.Shell do
  def shell(opts, mfa) do
    path =
      :code.priv_dir(:app)
      |> :filename.join(".iex.exs")

    opts = Keyword.put(opts, :dot_iex_path, path)
    IEx.start(opts, mfa)
  end
end
