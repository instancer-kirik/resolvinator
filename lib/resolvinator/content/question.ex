defmodule Resolvinator.Content.Question do
  use Flint.Schema
  use Resolvinator.Content.ContentBehavior,
    type_name: "question",
    table_name: "questions",
    relationship_table: "question_relationships",
    description_table: "question_descriptions"

  schema_field do
    # Q&A specific fields
    field :question_type, :string
    field :context, :string
    field :expected_answer_format, :string
    field :difficulty_level, :string
    field :is_answered, :boolean, default: false
    field :answer_count, :integer, default: 0
    field :accepted_answer_id, :binary_id

    # Relationships
    has_many :answers, Resolvinator.Content.Answer, foreign_key: :question_id
    belongs_to :accepted_answer, Resolvinator.Content.Answer

    # Topic/Category relationships
    many_to_many :topics, Resolvinator.Content.Topic,
      join_through: "question_topic_relationships"

    # Math-specific fields
    field :subject_area, :string  # algebra, calculus, number_theory, etc.
    field :theorem_references, {:array, :string}
    field :difficulty_rating, :integer  # 1-10 scale
    field :requires_proof, :boolean, default: false
    field :proof_technique_hints, {:array, :string}

    # Embedded math content
    embeds_one :math_content, Resolvinator.Content.MathContent

    # Additional relationships
    many_to_many :prerequisites, __MODULE__,
      join_through: "question_prerequisites",
      join_keys: [:question_id, :prerequisite_id]

    many_to_many :related_theorems, Resolvinator.Content.Theorem,
      join_through: "question_theorem_relationships"
  end

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
