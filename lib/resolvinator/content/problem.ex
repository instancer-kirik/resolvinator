defmodule Resolvinator.Content.Problem do

  alias Flint.Schema
  import Ecto.Changeset
  import Ecto.Query

  use Resolvinator.Content.ContentBehavior,
    type_name: :problem,
    table_name: "problems",
    relationship_table: "problem_relationships",
    description_table: "problem_descriptions",
    relationship_keys: [problem_id: :id, related_problem_id: :id],
    description_keys: [problem_id: :id, description_id: :id],
    additional_schema: [
      embeds_many: [
        impacts: [
          schema: %{
            area: :string,
            severity: :string,
            description: :string,
            estimated_cost: :decimal
          }
        ]
      ],
      relationships: [
        many_to_many: [
          users_with_problem: [
            module: Resolvinator.Accounts.User,
            join_through: "user_problems",
            join_keys: [problem_id: :id, user_id: :id],
            on_replace: :delete
          ]
        ]
      ]
    ]

  def changeset(problem, attrs) do
    problem
    |> base_changeset(attrs)
    |> cast_embed(:impacts)
    |> cast_assoc(:users_with_problem)
  end

  def users_with_problem_changeset(problem, users) do
    problem
    |> cast(%{}, [])
    |> put_assoc(:users_with_problem, users)
  end

  def add_impact(problem, impact_attrs) do
    impacts = (problem.impacts || []) ++ [impact_attrs]
    change(problem, %{impacts: impacts})
  end
end
