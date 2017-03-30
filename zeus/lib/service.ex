defmodule Zeus.Service do
  @moduledoc "Defines behaviour for services to implement."

  use Behaviour

  @doc "Called to generate a url. Naturally, gets called before the before/2 callback."
  defcallback generate_url(request :: Zeus.Http.ElliRequest.elli_req) :: String.t

  @doc "Before hook on requests to service that allows for the modification of headers."
  defcallback before_request(url :: String.t, headers :: list(tuple)) :: list(tuple)

  @doc "After hook on requests to service that allows for the modification of responses."
  defcallback after_response(response :: %Zeus.Http.Response{}) :: %Zeus.Http.Response{}
end
