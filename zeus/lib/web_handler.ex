defmodule Zeus.WebHandler do
  require Logger
  alias Zeus.Router, as: Router
  import Zeus.Http.ElliRequest

  @moduledoc """
  The root elli handler. Looks up resources in the router, then spawns up
  processes to collect resources and monitors them. Because of the way elli
  works, each call to handle/2 will be on a new process.
  """

  @behaviour :elli_handler

  @doc "Primary entry point for all requests."
  def handle(req, _args) do
    case Router.lookup(elli_req(req, :method), elli_req(req, :path)) do
      {resource_module, resource_action, resource_action_args, params} ->
        process_resource_response(req, resource_module, resource_action, resource_action_args, params)

      none ->
        error_response = %{ errors: [ "Path not found on server." ] }
        {404, default_json_headers, Poison.encode!(error_response, [])}
    end
  end

  def handle_event(:request_error, [_request, error, stacktrace], _config) do
    Logger.error "Error serving request!\n#{Exception.format :error, error, stacktrace}\n"
    :ok
  end

  def handle_event(:request_complete, [request, status, _headers, body, _], _config) do
    method = elli_req(request, :method)
    path = elli_req(request, :path)
    Logger.debug "Responded to #{method} #{path} with [#{status}] \"#{body}\"."
    :ok
  end

  def handle_event(:request_timeout, _args, _config) do
    Logger.error "A request timed out."
    :ok
  end

  @doc "Default elli event handler."
  def handle_event(event, args, _config) do
    Logger.info "Unhandled elli event: #{event} with args:\n#{inspect args}"
    :ok
  end

  @doc """
  Spawns a child process and awaits a response in the form of {:response, response}
  before the tiemout.

  Possible return values:
  - {:ok, response}
  - {:error, reason}
  - :timeout
  """
  def spawn_and_timeout(function, args, timeout) do
    Process.flag :trap_exit, true

    child_pid = Process.spawn_link function, args

    receive do
      {"EXIT", _, reason} -> {:error, reason}
      {:response, response} -> {:ok, response}
    after
      timeout -> :timeout
    end
  end

  # TODO: finish this
  @doc """
  Calls a resource action and formats a response. Handles errors and times out.
  """
  def process_resource_response(req, resource_module, resource_action, resource_action_args, params) do
    resource_data = resource_module.perform_action(req, resource_action, resource_action_args, params)
    {200, default_json_headers, Poison.encode!(resource_data, [])}
  end

  defp default_json_headers do
    [{"Content-Type", "application/json"}]
  end
end
