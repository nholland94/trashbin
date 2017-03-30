defmodule Zeus do
  use Application

  def start(_type, _args) do
    Zeus.Supervisor.start_link
  end
end
