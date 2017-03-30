defmodule Zeus.Services.MediaManager do
  alias Zeus.Http.ElliRequest, as: ElliRequest
  import Zeus.Http.Exceptions
  @behaviour Zeus.Service

  def generate_url(request) do
    case :elli_request.get_header("Domain", request) do
      :undefined -> raise BadRequestException, message: "\"domain\" not found in headers"
      domain     -> "https://" <> domain
    end
  end

  def before_request(_url, headers) do
    headers
  end

  def after_response(response) do
    response
  end
end
