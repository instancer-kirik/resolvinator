defmodule Resolvinator.Content.Question do
  use Flint.Schema

  use Resolvinator.Content.ContentBehavior,
    type_name: :question,
    table_name: "questions",
    relationship_table: "question_relationships",
    description_table: "question_descriptions",
    relationship_keys: [question_id: :id, related_question_id: :id],
    description_keys: [question_id: :id, description_id: :id],
    additional_schema: [
      fields: [
        question_type: :string,
        context: :string,
        expected_answer_format: :string,
        difficulty_level: :string,
        is_answered: {:boolean, default: false},
        answer_count: {:integer, default: 0},
        subject_area: :string,
        theorem_references: {:array, :string},
        difficulty_rating: :integer,
        requires_proof: {:boolean, default: false},
        proof_technique_hints: {:array, :string}
      ],
      embeds_one: [
        math_content: [module: Resolvinator.Content.MathContent]
      ],
      relationships: [
        has_many: [
          answers: [module: Resolvinator.Content.Answer]
        ],
        belongs_to: [
          accepted_answer: [module: Resolvinator.Content.Answer]
        ],
        many_to_many: [
          topics: [
            module: Resolvinator.Content.Topic,
            join_through: "question_topic_relationships"
          ],
          prerequisites: [
            module: __MODULE__,
            join_through: "question_prerequisites",
            join_keys: [question_id: :id, prerequisite_id: :id]
          ],
          related_theorems: [
            module: Resolvinator.Content.Theorem,
            join_through: "question_theorem_relationships"
          ]
        ]
      ]
    ]

  def changeset(question, attrs) do
    question
    |> base_changeset(attrs)
    |> cast(attrs, [
      :question_type, :context, :expected_answer_format,
      :difficulty_level, :is_answered, :accepted_answer_id,
      :subject_area, :theorem_references, :difficulty_rating,
      :requires_proof, :proof_technique_hints
    ])
    |> cast_embed(:math_content)
    |> validate_inclusion(:question_type, ~w(general technical process clarification))
    |> validate_inclusion(:difficulty_level, ~w(beginner intermediate advanced expert))
    |> validate_inclusion(:subject_area, ~w(
      algebra analysis calculus geometry
      number_theory logic combinatorics probability
    ))
    |> validate_number(:difficulty_rating, greater_than: 0, less_than_or_equal_to: 10)
    |> foreign_key_constraint(:accepted_answer_id)
  end
end
