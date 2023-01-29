defmodule Dpi.App.Shell do
  alias Dpi.Api.Env

  defmacro __using__(_opts) do
    path =
      :code.priv_dir(:dpi_app)
      |> :filename.join("iex.exs")

    path
    |> File.read!()
    |> Code.string_to_quoted!(file: path)
  end

  # applications can override .iex file
  # double file not supported iex/evaluator.ex#L245
  def start(opts, mfa) do
    path =
      with true <- Env.in_rt(),
           path <-
             Env.app_name()
             |> :code.priv_dir()
             |> :filename.join("iex.exs"),
           true <- File.regular?(path) do
        path
      else
        _ ->
          :code.priv_dir(:dpi_app)
          |> :filename.join("iex.exs")
      end

    opts = Keyword.put(opts, :dot_iex_path, path)
    IEx.start(opts, mfa)
  end

  # mix dpi.eval 'raise "hello"'
  #   - throws %RuntimeError
  #   - script is rescued
  # mix dpi.eval 'raise 1'
  #   - throws %ArgumentError
  #   - script is rescued
  # mix dpi.eval 'Process.exit(self(), :stop)'
  #   - receives an EXIT message
  # mix dpi.eval 'Agent.start_link(fn -> nil end, name: :dpi_eval_script)'
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
        catch
          :exit, e ->
            IO.inspect({:exit, e})
            IO.inspect(__STACKTRACE__)

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
        if reason != :done, do: IO.inspect(reason)
        Process.exit(self(), :killed)

      msg ->
        # did the remote died?
        raise "Unexpected #{inspect(msg)}"
    end
  end
end
