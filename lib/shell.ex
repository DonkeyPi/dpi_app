defmodule Ash.App.Shell do
  require Ash.App

  # applications can override .iex file
  # double file not supported iex/evaluator.ex#L245
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

  def capture_eval(pid, code) do
    Process.link(pid)

    try do
      Code.eval_string(code)
    rescue
      e ->
        # better formatting printing from source
        IO.inspect(e)
        IO.inspect(__STACKTRACE__)
        :rescued
    after
      # unlink so that the calling process wont
      # get killed before getting rpc response
      Process.unlink(pid)
    end
  end
end
