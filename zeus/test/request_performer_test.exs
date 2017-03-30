defmodule RequestPerformerTest do
  use ExUnit.Case

  import Zeus.Http.RequestPerformer
  doctest Zeus.Http.RequestPerformer

  def placeholder_api(path) do
    "http://jsonplaceholder.typicode.com" <> path
  end

  test "single, simple request" do
    request = [
      url: placeholder_api("/posts/1"),
      method: :GET,
      headers: [],
      body: ""
    ]

    response = perform_request(request, [before: [], after: []])

    assert Dict.has_key?(response, :title)
    assert Dict.has_key?(response, :body)
  end
end
