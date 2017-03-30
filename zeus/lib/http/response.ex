defmodule Zeus.Http.Response do
  @moduledoc "Struct module designed for internal use when returning ibrowse responses."

  defstruct [:status, :headers, :body]

  def new(status, headers, body) do
    %__MODULE__{
      status: status,
      headers: headers,
      body: body
    }
  end

  @doc "Formats a Zeus.Http.Response into an elli response tuple."
  def format_elli_response(%__MODULE__{status: status, headers: headers, body: body}) do
    {status, headers, body}
  end
end
