defmodule Resolvinator.Content.Problem do
  import Ecto.Changeset

  use Resolvinator.Content.ContentBehavior,
    type_name: :problem,
    table_name: "problems",
    relationship_table: "problem_relationships",
    description_table: "problem_descriptions",
    relationship_keys: [problem_id: :id, related_problem_id: :id],
    description_keys: [problem_id: :id, description_id: :id],
    additional_schema: [
      relationships: [
        many_to_many: [
          users_with_problem: [
            module: Resolvinator.Acts.User,
            join_through: "user_problems",
            join_keys: [problem_id: :id, user_id: :id],
            on_replace: :delete
          ]
        ],
        has_many: [
          mitigations: [
            module: Resolvinator.Content.Mitigation
          ]
        ]
      ]
    ]

  def changeset(problem, attrs) do
    problem
    |> base_changeset(attrs)
    |> cast_assoc(:users_with_problem)
    |> cast_assoc(:mitigations)
  end

  def users_with_problem_changeset(problem, users) do
    problem
    |> cast(%{}, [])
    |> put_assoc(:users_with_problem, users)
  end
end
