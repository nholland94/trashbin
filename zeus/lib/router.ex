# TODO: remove elli handler, create queryable api
defmodule Zeus.Router do
  use Zeus.DSL.Router

  full_rest_resource "/meetings", meeting: [:id, :guid]

  def resolve_args(_resource, [:id, :guid], [value]) do
    if Regex.match? ~r/^\d+$/, value do
      :id
    else
      :guid
    end
  end
end
