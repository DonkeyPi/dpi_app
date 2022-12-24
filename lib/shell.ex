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

  # mix ash.eval 'raise "hello"'
  #   - throws %RuntimeError
  #   - script is rescued
  # mix ash.eval 'raise 1'
  #   - throws %ArgumentError
  #   - script is rescued
  # mix ash.eval 'Process.exit(self(), :stop)'
  #   - receives an EXIT message
  # mix ash.eval 'Agent.start_link(fn -> nil end, name: :ash_eval_script)'
  #   - to test that previous script has died

  def capture_eval(pid, code) do
    Process.link(pid)
    Process.flag(:trap_exit, true)

    child =
      spawn_link(fn ->
        try do
          res = Code.eval_string(code)
          IO.inspect(res)
        rescue
          e ->
            IO.inspect(e)
            IO.inspect(__STACKTRACE__)
        after
          # kill process started by the script
          Process.exit(self(), :done)
        end
      end)

    # - Exit of the parent must kill the child
    # - Exit of the child must be catched by the parent
    # - Linking the child is catcheable but it transitively
    #   kills the remote process before responding.
    # - Not linking the child wont't kill processes started
    #   by the script.

    # The compromise is to log the result locally and exit
    # abnormally to propagate the shutdown of all linked
    # processes.
    receive do
      {:EXIT, ^child, reason} ->
        # better formatting from source
        IO.inspect(reason)
        Process.exit(self(), :killed)

      msg ->
        # did the remote died?
        raise "unexpected #{inspect(msg)}"
    end
  end
end
