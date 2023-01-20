defmodule Dpi.App.Console do
  def home() do
    Process.send({Dpi.Term.Server, :dpi_console@localhost}, {:select, :home}, [:noconnect])
  end
end
