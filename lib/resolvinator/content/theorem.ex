defmodule Resolvinator.Content.Theorem do
  use Flint.Schema

  use Resolvinator.Content.ContentBehavior,
    type_name: :theorem,
    table_name: "theorems",
    relationship_table: "theorem_relationships",
    description_table: "theorem_descriptions",
    relationship_keys: [theorem_id: :id, related_theorem_id: :id],
    description_keys: [theorem_id: :id, description_id: :id],
    additional_schema: [
      fields: [
        formal_statement: {:string, []},
        proof_strategy: :string,
        complexity_level: :string,
        prerequisites: {:array, :string},
        field_of_study: :string,
        notation_used: :map
      ],
      relationships: [
        many_to_many: [
          questions: [
            module: Resolvinator.Content.Question,
            join_through: "question_theorem_relationships",
            join_keys: [theorem_id: :id, question_id: :id]
          ]
        ]
      ]
    ]

  def changeset(theorem, attrs) do
    theorem
    |> base_changeset(attrs)
    |> cast(attrs, [
      :formal_statement, :proof_strategy, :complexity_level,
      :prerequisites, :field_of_study, :notation_used
    ])
    |> validate_inclusion(:complexity_level, ~w(basic intermediate advanced expert))
    |> validate_inclusion(:field_of_study, ~w(
      algebra analysis calculus geometry
      number_theory logic combinatorics probability
    ))
  end
end 