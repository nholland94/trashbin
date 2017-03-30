defmodule Zeus.Http.RequestPerformer do
  alias Zeus.Http.Request, as: Request
  alias Zeus.Http.Response, as: Response

  @moduledoc "Provides functions for performing requests with before and after hooks."

  @doc """
  Performs bulk requests asynchronously, returning a keyword list of responses.
  The requests variable should be a dict of requests to perform. The key of each
  request will be the key in the return dict where the response is stored.
  """
  def perform_requests(requests, hooks) do
    this = self()
    perform_request_and_notify_self = fn(request_key) ->
      response = perform_request(requests[request_key], hooks)

      send this, {:response, request_key, response}
    end

    request_keys = Dict.keys(requests)

    Enum.map Dict.keys(requests), fn(request) ->
      Process.spawn_link(perform_request_and_notify_self, [request])
    end

    receive_perform_request_responses(request_keys)
  end

  defp receive_perform_request_responses(request_keys) do
    receive_perform_request_responses(request_keys, [])
  end

  defp receive_perform_request_responses(request_keys, responses) do
    receive do
      {:response, response_key, response} ->
        request_keys = Dict.delete(request_keys, response_key)
        responses = responses ++ [{response_key, response}]

        if request_keys == [] do
          responses
        else 
          receive_perform_request_responses(request_keys, responses)
        end
    end
  end

  @doc "Performs a single request synchronously, with hooks."
  def perform_request(%Request{url: url, method: method, headers: headers, body: body}, [before: before_hooks, after: after_hooks]) do
    [_, headers] = List.foldl before_hooks, [url, headers], fn(hook, args) ->
      [url, _] = args
      [url, apply(hook, args)]
    end

    case :ibrowse.send_req(url, headers, method, body) do
      {:error, error} ->
        raise (Exception.normalize :error, error)

      {:ok, response_status, response_headers, response_body} ->
        response = Response.new response_status, response_headers, response_body

        List.foldl after_hooks, response, fn(response, hook) -> hook.(response) end
    end
  end
end
