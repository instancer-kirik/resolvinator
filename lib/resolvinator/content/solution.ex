defmodule Resolvinator.Content.Solution do
  use Flint.Schema

  use Resolvinator.Content.ContentBehavior,
    type_name: :solution,
    table_name: "solutions",
    relationship_table: "solution_relationships",
    description_table: "solution_descriptions",
    relationship_keys: [solution_id: :id, related_solution_id: :id],
    description_keys: [solution_id: :id, description_id: :id],
    additional_schema: [
      relationships: [
        many_to_many: [
          users_with_solution: [
            module: Resolvinator.Accounts.User,
            join_through: "user_solutions",
            join_keys: [solution_id: :id, user_id: :id],
            on_replace: :delete
          ]
        ]
      ]
    ]

  def changeset(solution, attrs) do
    solution
    |> base_changeset(attrs)
    |> cast_assoc(:users_with_solution)
  end

  def users_with_solution_changeset(solution, users) do
    solution
    |> cast(%{}, [])
    |> put_assoc(:users_with_solution, users)
  end
end
