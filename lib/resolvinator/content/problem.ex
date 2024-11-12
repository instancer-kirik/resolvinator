defmodule Resolvinator.Content.Problem do
  use Flint.Schema

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
          module: Resolvinator.Content.Impact
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
    |> cast_embed(:impacts)
    |> cast_assoc(:users_with_problem)
    |> cast_assoc(:mitigations)
  end

  def users_with_problem_changeset(problem, users) do
    problem
    |> cast(%{}, [])
    |> put_assoc(:users_with_problem, users)
  end
end
