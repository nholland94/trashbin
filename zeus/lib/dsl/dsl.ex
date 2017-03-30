defmodule Zeus.DSL do
  @moduledoc "Provides helper functions to other dsl modules."

  @doc """
  Wraps a quote or list of quotes in a block. If the root element is already a block,
  nothing is done.
  """
  def blockify(ast) do
    case ast do
      {:__block__, _, _} ->
        ast

      ast when is_list(ast) ->
        {:__block__, [], ast}

      ast when not is_list(ast) ->
        {:__block__, [], [ast]}
    end
  end

  @doc """
  Creates a list head/tail statement ([a | b]) with two variables. If any of the
  variables is :underscore, then it replaces that value with a syntax "_".
  """
  def list_head_tail(head, tail) do
    list_ast_parts = Enum.map [head, tail], fn(value) ->
      if tail == :underscore do
        {:_, [], Elixir}
      else
        tail
      end
    end

    [{:|, [], list_ast_parts}]
  end

  @doc """
  Prefixes all function calls in a block with a string. Skips function calls
  that are aliased to a module already. 
  """
  def prefix_function_names_in_block(function_prefix, do: block) do
    {:__block__, attrs, statements} = blockify(block)

    statements = Enum.map statements, fn(statement) ->
      case statement do
        {atom, attrs, args} when is_atom(atom) ->
          function_name = function_prefix <> Atom.to_string(atom)
          {String.to_atom(function_name), attrs, args}

        _ ->
          statement
      end
    end

    {:__block__, attrs, statements}
  end

  @doc """
  Generates a mixin quote from a module. The quote delegates all of the
  module's functions to whatever module executes it. Also enables
  overriding of functions delegated this way.

  Taken from https://gist.github.com/orenbenkiki/5174435.
  """
  def generate_mixin_from_module(module) do
    functions = module.__info__(:functions)
    signatures = Enum.map functions, fn { name, arity } ->
      args =
        if arity == 0 do
          []
        else
          Enum.map 1 .. arity, fn(i) ->
            { String.to_atom(<< ?x, ?A + i - 1 >>), [], nil }
          end
        end

      { name, [], args }
    end

    quote do
      defdelegate unquote(signatures), to: unquote(module)
      defoverridable unquote(functions)
    end
  end

  def join_blocks(blocks) do
    new_block_body = Enum.reduce blocks, [], fn(block, acc) ->
      {:__block__, _, body} = block
      acc ++ body
    end

    {:__block__, [], new_block_body}
  end

  # Pretty hacky... I think I probably shouldn't do this kind of stuff.
  def hack_variable_refs(ast, variable_name) do
    case ast do
      {variable_name, metadata, nil} -> {variable_name, metadata, Elixir}
      {other_atom, args}             -> {other_atom, hack_variable_refs(args, variable_name)}
      {other_atom, metadata, args}   -> {other_atom, metadata, hack_variable_refs(args, variable_name)}
      ls when is_list(ls)            -> Enum.map ls, (&hack_variable_refs &1, variable_name)
      other_ast                      -> other_ast
    end
  end
end
