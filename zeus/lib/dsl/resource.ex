defmodule Zeus.DSL.Resource do
  require Zeus.DSL

  defmodule ActionRequestCallbackAlreadyDefined do
    defexception [:message, :module, :action]

    def exception([module, action]) do
      %__MODULE__{
        message: "The request callback was already defined for action \"#{action}\" on \"#{module}\". Did you define an endpoint and a request callback? Or multiple request callbacks?",
        module: module,
        action: action
      }
    end
  end

  defmodule ActionNotFound do
    defexception [:message, :module, :action]

    def exception([module, action]) do
      %__MODULE__{
        message: "Cannot find action \"#{}\" on \"#{module}\".",
        module: module,
        action: action

      }
    end
  end

  @moduledoc """
  A "usable" module that provides a dsl for defining resources.
  """

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      require IEx

      @actions %{}

      @before_compile unquote(__MODULE__)
    end
  end

  @doc """
  Configures a whole set of rest actions for the resource. Id args are used as
  action args on the show, update, and destroy actions.
  """
  defmacro full_rest_actions(service, id_args, base_path) do
    id_path = "#{base_path}/$"

    quote do
      basic_action :index, [], unquote({service, :GET, base_path})
      basic_action :create, [], {unquote(service), :POST, unquote(base_path)}
      basic_action :show, unquote(id_args), {unquote(service), :GET, unquote(id_path)}
      basic_action :update, unquote(id_args), {unquote(service), :PUT, unquote(id_path)}
      basic_action :destroy, unquote(id_args), {unquote(service), :DELETE, unquote(id_path)}
    end
  end

  @doc "Configure a single action to route directly to a service request."
  defmacro basic_action(name, args, {service, method, path}) do
    quote do
      action unquote(name), unquote(args) do
        endpoint unquote(service), unquote(method), unquote(path)
      end
    end
  end

  defmacro action(name, do: block) do
    quote do
      action unquote(name), [], do: unquote(block)
    end
  end

  defmacro action(name, arg, do: block) when not is_list(arg) do
    quote do
      action unquote(name), [unquote(arg)], do: unquote(block)
    end
  end

  @doc """
  Define an action configuration block. Function calls inside are prefixed with
  "action_" and have a first argument injected to notify the function of the
  action's name.
  """
  defmacro action(name, args, do: block) when is_list(args) do
    {:__block__, _, block_body} = Zeus.DSL.blockify block
    function_prefix = "action_"

    block_body = Enum.map block_body, fn(function_call) ->
      case function_call do
        {function_name, tags, function_args} when is_atom(function_name) ->
          prefixed_function_name = function_prefix <> Atom.to_string(function_name)
          {String.to_atom(prefixed_function_name), tags, [name | function_args]}

        # not sure if this is necessary
        _ ->
          function_call
      end
    end

    initialize_action_quote = quote do
      @actions Dict.put_new @actions, unquote(name), %{}
    end

    {:__block__, [], [initialize_action_quote | block_body]}
  end

  @doc """
  Configures an action's request generator to map to a static service request.
  """
  defmacro action_endpoint(name, service, method, path) do
    quote do
      action_request unquote(name) do
        {unquote(service), unquote(method), unquote(path)}
      end
    end
  end

  # NOTE:
  # Right now, this injects a "magic" argument called params.
  # I don't know if I like this. It may be better to support a
  # syntax like `request(params) do ... end`.

  @doc """
  Configures an action's request generator.
  """
  defmacro action_request(name, do: callback_body) do
    callback_name = (Enum.join ["action", name, "request_callback"], "_")
      |> String.to_atom

    if Module.defines? __CALLER__.module, {callback_name, 1}, :def do
      raise ActionRequestCallbackAlreadyDefined, [__CALLER__.module, name]
    end

    callback_body = Zeus.DSL.hack_variable_refs callback_body, :params

    # Can't generate this ast with a quote or the argument won't be scoped properly
    callback_def = {:def, [context: __CALLER__.module, import: Kernel], [
      {callback_name, [context: __CALLER__.module], [{:params, [], Elixir}]},
      [do: callback_body]]}

    quote do
      unquote(callback_def)

      @actions Dict.update! @actions, unquote(name), fn(action) ->
        Dict.put_new action, :request_callback, &__MODULE__.unquote(callback_name)/1
      end
    end
  end

  @mixin (quote do
    def perform_action(request, action, args, params) do
      if !Dict.has_key?(@actions, action), do: raise Zeus.DSL.Resource.ActionNotFound, [__MODULE__, action]

      {service_module, method, path, body} = case @actions[action][:request_callback].(params) do
        {service_module, method, path, body} -> {service_module, method, path, body}
        {service_module, method, path} -> {service_module, method, path, ""}
      end

      service_module = try do
        Module.safe_concat Zeus.Services, service_module
      rescue
        ArgumentError -> raise Zeus.DSL.Resource.ServiceNotFound, service_module
      end

      resource_request = Zeus.Http.Request.new "", method, %{}, body
      resource_request = %{ resource_request | url: (service_module.generate_url request) }

      hooks = [before: [&service_module.before_request/2], after: [&service_module.after_response/1]]
      response = Zeus.Http.RequestPerformer.perform_request resource_request, hooks

      # TODO: some kind of transformation hooks for the resource

      response
    end
  end)

  defmacro __before_compile__(_env) do
    @mixin
  end
end
