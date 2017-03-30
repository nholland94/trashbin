defmodule Zeus.Supervisor do
  require Logger

  @moduledoc "Root application supervisor."

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    port = Application.get_env(:zeus, :port)
    Logger.info("Booting elli with port #{port}")

    children = [
      worker(:elli, [[callback: Zeus.WebHandler, port: port]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
