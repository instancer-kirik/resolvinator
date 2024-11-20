defmodule Resolvinator.Contexts do
  @moduledoc """
  The Contexts module provides a structured way to organize and access different
  contexts within the Resolvinator application.
  """

  alias Resolvinator.{Resolvers, Projects, Shared}

  @doc """
  Returns the context configuration for the given context type.
  """
  def get_context(context_type) when is_atom(context_type) do
    Application.get_env(:resolvinator, :contexts)[context_type]
  end

  @doc """
  Returns all available contexts.
  """
  def list_contexts do
    Application.get_env(:resolvinator, :contexts)
  end

  @doc """
  Returns the base module for a given context type.
  """
  def base_module(context_type) when is_atom(context_type) do
    case context_type do
      :resolvers -> Resolvers
      :projects -> Projects
      :shared -> Shared
      _ -> raise "Unknown context type: #{inspect(context_type)}"
    end
  end

  @doc """
  Returns the path for a given context type.
  """
  def context_path(context_type) when is_atom(context_type) do
    case get_context(context_type) do
      %{path: path} -> path
      _ -> raise "Context path not found for: #{inspect(context_type)}"
    end
  end

  @doc """
  Returns all modules in a given context.
  """
  def list_modules(context_type) when is_atom(context_type) do
    base = base_module(context_type)
    
    :code.all_loaded()
    |> Enum.filter(fn {module, _} ->
      module_string = Atom.to_string(module)
      String.starts_with?(module_string, Atom.to_string(base))
    end)
    |> Enum.map(fn {module, _} -> module end)
  end

  @doc """
  Checks if a module belongs to a specific context.
  """
  def in_context?(module, context_type) when is_atom(module) and is_atom(context_type) do
    base = base_module(context_type)
    module_string = Atom.to_string(module)
    String.starts_with?(module_string, Atom.to_string(base))
  end
end
