defmodule Resolvinator.Content.Problem do
  use Ecto.Schema
  use Flint.Schema
  @derive {Jason.Encoder, only: [:id, :name, :desc, :status, :metadata]}

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
          ],
          related_risks: [
            module: Resolvinator.Risks.Risk,
            join_through: "problem_risk_relationships",
            join_keys: [problem_id: :id, risk_id: :id],
            on_replace: :delete
          ]
        ],
        has_many: [
          mitigations: [
            module: Resolvinator.Risks.Mitigation,
            foreign_key: :problem_id
          ]
        ]
      ]
    ]

  def changeset(problem, attrs) do
    problem
    |> base_changeset(attrs)
    |> cast_embed(:impacts, with: &Resolvinator.Content.Impact.changeset/2)
    |> cast_assoc(:users_with_problem)
    |> cast_assoc(:mitigations)
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
