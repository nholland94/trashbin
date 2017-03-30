defmodule Zeus.Http.ElliRequest do
  @moduledoc "Wraps elli's elixir record with an elixir record."

  require Record
  Record.defrecord :elli_req, Record.extract(:req, from: "deps/elli/include/elli.hrl")

  @type elli_req :: record(:elli_req,
    method: String.t,
    path: [String.t],
    args: [{String.t, any}],
    raw_path: String.t,
    version: {integer, integer},
    headers: [{String.t, String.t}],
    body: String.t | list,
    pid: pid,
    socket: any, # too hard to translate
    callback: {module, any}
  )
end
