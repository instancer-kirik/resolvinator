defmodule Resolvinator.Projects.NestedTerm do
  @moduledoc """
  Handles nested terms within projects, allowing for hierarchical organization
  of project-related concepts and metadata.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Resolvinator.Projects.Project

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "project_nested_terms" do
    field :key, :string
    field :value, :map
    field :path, {:array, :string}
    field :metadata, :map, default: %{}
    field :parent_key, :string
    field :order, :integer
    field :is_terminal, :boolean, default: true
    
    belongs_to :project, Project
    belongs_to :parent, __MODULE__, type: :binary_id

    has_many :children, __MODULE__, foreign_key: :parent_id
    
    timestamps()
  end

  @required_fields ~w(key project_id)a
  @optional_fields ~w(value path metadata parent_key parent_id order is_terminal)a

  @doc """
  Creates a changeset for a nested term.
  """
  def changeset(nested_term, attrs) do
    nested_term
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_key_format()
    |> validate_path_format()
    |> set_path_from_parent()
    |> set_terminal_status()
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:parent_id)
  end

  @doc """
  Creates a tree structure from a list of nested terms.
  """
  def build_tree(terms) when is_list(terms) do
    terms
    |> Enum.sort_by(& &1.order || 0)
    |> Enum.reduce(%{}, fn term, acc ->
      path = term.path || []
      put_in(acc, Enum.map(path ++ [term.key], &Access.key(&1, %{})), term)
    end)
  end

  @doc """
  Flattens a tree structure back into a list of nested terms.
  """
  def flatten_tree(tree, parent_path \\ [], acc \\ []) do
    Enum.reduce(tree, acc, fn {key, value}, acc ->
      current_path = parent_path ++ [key]
      
      case value do
        %__MODULE__{} = term ->
          [%{term | path: parent_path} | acc]
          
        %{} = subtree when map_size(subtree) > 0 ->
          flatten_tree(subtree, current_path, acc)
          
        _ ->
          acc
      end
    end)
  end

  @doc """
  Validates that a term exists at the given path.
  """
  def validate_term_at_path(project_id, path) when is_list(path) do
    # Implementation depends on your query interface
    true
  end

  # Private functions

  defp validate_key_format(changeset) do
    validate_change(changeset, :key, fn :key, key ->
      if String.match?(key, ~r/^[a-z][a-z0-9_]*$/) do
        []
      else
        [key: "must be lowercase alphanumeric with underscores, starting with a letter"]
      end
    end)
  end

  defp validate_path_format(changeset) do
    validate_change(changeset, :path, fn :path, path ->
      if is_nil(path) or (is_list(path) and Enum.all?(path, &is_binary/1)) do
        []
      else
        [path: "must be a list of strings"]
      end
    end)
  end

  defp set_path_from_parent(changeset) do
    if get_change(changeset, :parent_id) do
      parent = get_field(changeset, :parent)
      
      if parent do
        parent_path = parent.path || []
        put_change(changeset, :path, parent_path ++ [parent.key])
      else
        changeset
      end
    else
      changeset
    end
  end

  defp set_terminal_status(changeset) do
    if get_change(changeset, :value) do
      put_change(changeset, :is_terminal, true)
    else
      changeset
    end
  end
end
