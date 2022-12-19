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

    parent = self()

    child =
      spawn_link(fn ->
        try do
          res = Code.eval_string(code)
          send(parent, {:result, self(), res})
        rescue
          e -> send(parent, {:rescue, self(), e, __STACKTRACE__})
        end

        # kill process started by the script
        Process.exit(self(), :done)
      end)

    # - Exit of the parent must kill the child
    # - Exit of the child must be catched by the parent
    # - Linking the child is catcheable but it transitively
    #   kills the remote process before responding.
    # - Not linking the child wont't kill processes started
    #   by the script.

    # The compromise is to log the result locally and just send a
    # atom response to 'ensure' the response is displayed before
    # the killing chain reaches the remote process.
    result =
      receive do
        {:result, ^child, res} ->
          IO.inspect(res)
          :done

        {:rescue, ^child, e, st} ->
          # better formatting from source
          IO.inspect(e)
          IO.inspect(st)
          :rescued

        {:EXIT, ^child, reason} ->
          # better formatting from source
          IO.inspect(reason)
          :killed

        msg ->
          # did the remote died?
          raise "unexpected #{inspect(msg)}"
      end

    # unlink so that the calling process wont
    # get killed before getting rpc response
    Process.unlink(pid)

    result
  end
end
