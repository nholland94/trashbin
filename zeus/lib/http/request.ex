defmodule Zeus.Http.Request do
  @moduledoc "Struct module designed for internal use when forming ibrowse requests."

  defstruct [:url, :method, :headers, :body]

  def new(url \\ "", method \\ :GET, headers \\ %{}, body \\ "") do
    %__MODULE__{
      url: url,
      method: method,
      headers: headers,
      body: body 
    }
  end
end
