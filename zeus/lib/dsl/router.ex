defmodule Zeus.DSL.Router do
  require Zeus.DSL

  defmodule NoConflictResolutionDefined do
    defexception [:message, :resource, :conflict]

    def exception([resource, conflict]) do
      %__MODULE__{
        message: "You must define a resolve_args/3 to resolve the conflict #{conflict} for #{resource}!",
        resource: resource,
        conflict: conflict
      }
    end
  end

  defmodule Route do
    defstruct [:method, :path, :resource, :action, :action_args]

    def new(method, path, resource, action, action_args) do
      %__MODULE__{
        method: method,
        path: path,
        resource: resource,
        action: action,
        action_args: action_args
      }
    end
  end

  defmodule PathMatcher do
    def build_path_matcher_from_path(path) do
      Regex.replace(~r/\/+/, path, "/")
        |> String.strip(?/)
        |> String.split("/")
        |> Enum.map(fn(subpath) ->
          if subpath == "*" do
            :wildcard
          else
            subpath
          end
        end)
    end

    def generate_pattern_matching_quote(path_matcher) do
      Enum.map path_matcher, fn(element) ->
        if element == :wildcard do
          quote do: _
        else
          element
        end
      end
    end

    def match_args_in_path(path_matcher, path) do
      Enum.filter(Enum.zip(path_matcher, path), fn({path_matcher_element, _path_element}) ->
        path_matcher_element == :wildcard
      end)
        |> Enum.map(fn({_path_matcher_element, path_element}) ->
          path_element
        end)
    end
  end

  @moduledoc """
  # TODO
  Update this module's documentation.

  A "usable" module that provides a resource routing dsl. Designed to work with
  elli handlers that forwards calls from handle/2 to handle/4, adding 2 arguments
  at the beginning set to the request method and path. This requirement enables
  pattern matching on function definitions.
  """

  @doc """
  Use callback. Import dsl for use, setup tail value for @routes attribute,
  and tag this module to be run before compilation.
  """
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @routes []

      @before_compile unquote(__MODULE__)
    end
  end

  # can't specify neat default ("\\" syntax) with multiple function clauses
  defmacro resource_route(method, path, resource, action) do
    quote do
      resource_route unquote(method), unquote(path), unquote(resource), unquote(action), []
    end
  end

  defmacro resource_route(method, path, resource, action, action_args) when not is_list(action_args) do
    quote do
      resource_route unquote(method), unquote(path), unquote(resource), unquote(action), unquote([action_args])
    end
  end

  @doc "Configures a route that points to a resource action."
  defmacro resource_route(method, path, resource, action, action_args) do
    route_entry_quote = quote do
      Route.new unquote(method), unquote(path), unquote(resource), unquote(action), unquote(action_args)
    end

    quote do
      @routes [unquote(route_entry_quote) | @routes]
    end
  end

  defmacro full_rest_resource(path, resource) when not is_list(resource) do
    quote do
      full_rest_resource unquote(path), [{ unquote(resource), [:id] }]
    end
  end

  defmacro full_rest_resource(path, [{resource, field}]) when not is_list(field) do
    quote do
      full_rest_resource unquote(path), [{ unquote(resource), [unquote(field)] }]
    end
  end

  @doc "Configures a set of rest actions at a given base endpoint to a given resource."
  defmacro full_rest_resource(path, [{resource, fields}]) do
    matching_path = path <> "/*"

    quote do
      resource_route :GET, unquote(path), unquote(resource), :index
      resource_route :POST, unquote(path), unquote(resource), :create
      resource_route :GET, unquote(matching_path), unquote(resource), :show, unquote(fields)
      resource_route :PUT, unquote(matching_path), unquote(resource), :update, unquote(fields)
      resource_route :DELETE, unquote(matching_path), unquote(resource), :destroy, unquote(fields)
    end
  end

  defp find_module_of_resource_atom(resource) do
    resource_module_atom = (Atom.to_string resource) |> (String.capitalize) |> (String.to_atom)
    Module.safe_concat(Zeus.Resources, resource_module_atom)
  end

  defp build_route_lookup(%Route{method: method, path: path, resource: resource, action: action, action_args: action_args}) do
    path_matcher = PathMatcher.build_path_matcher_from_path(path)
    resource_module = find_module_of_resource_atom(resource)

    quote do
      def lookup(unquote(method), unquote(PathMatcher.generate_pattern_matching_quote(path_matcher)) = path) do
        matched_args = Zeus.DSL.Router.PathMatcher.match_args_in_path(unquote(path_matcher), path)

        {unquote(resource_module), unquote(action), resolve_args(unquote(resource), unquote(action_args), matched_args), matched_args}
      end
    end
  end

  defp build_lookups_from_routes(routes, lookup_quotes \\ []) do
    case routes do
      [route | tail] ->
        build_lookups_from_routes tail, [build_route_lookup(route) | lookup_quotes]

      [] -> lookup_quotes
    end
  end

  @resolve_args_helpers (quote do
    def resolve_args(_resource, [arg], [_value]) do
      [arg]
    end

    def resolve_args(_resource, [], []) do
      []
    end
  end)

  @function_fallbacks (quote do
    def lookup(method, path) do
      :not_found
    end

    def resolve_args(resource, conflict, _value) do
      raise NoConflictResolutionDefined, [resource, conflict]
    end
  end)

  @doc """
  Before compile callback. Generates lookup definitons from @routes.
  """
  defmacro __before_compile__(env) do
    lookup_quotes = Zeus.DSL.blockify build_lookups_from_routes(Module.get_attribute(env.module, :routes))
    Zeus.DSL.join_blocks [@resolve_args_helpers, lookup_quotes, @function_fallbacks]
  end
end
