defmodule Resolvinator.Content.Problem do
  @moduledoc """
  Schema and functions for Problems
  """

  use Flint.Schema
  use Resolvinator.Content.ContentBehavior,
    type_name: :problem,
    table_name: "problems",
    relationship_table: "problem_relationships",
    relationship_keys: [problem_id: :id, related_problem_id: :id],
    description_table: "problem_descriptions",
    description_keys: [:problem_id, :language_id]

  flint do
    many_to_many :users_with_problem, Resolvinator.Accounts.User,
      join_through: "user_problems",
      on_replace: :delete
  end

  # Problem-specific functions
  def users_with_problem_changeset(problem, users) do
    problem
    |> cast(%{}, [])
    |> put_assoc(:users_with_problem, users)
  end

  def changeset(problem, attrs) do
    problem
    |> super(attrs)
    |> cast_assoc(:users_with_problem)
  end
end
