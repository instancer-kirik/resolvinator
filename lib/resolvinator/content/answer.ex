defmodule Resolvinator.Content.Answer do
  import Ecto.Changeset

  use Resolvinator.Content.ContentBehavior,
    type_name: :answer,
    table_name: "answers",
    relationship_table: "answer_relationships",
    description_table: "answer_descriptions",
    relationship_keys: [answer_id: :id, related_answer_id: :id],
    description_keys: [answer_id: :id, description_id: :id],
    additional_schema: [
      fields: [
        content: :string,
        answer_type: :string,
        is_accepted: {:boolean, default: false},
        references: {:array, :string},
        code_snippets: {:array, :map},
        votes: {:integer, default: 0}
      ],
      relationships: [
        belongs_to: [
          question: [module: Resolvinator.Content.Question],
          user: [module: Resolvinator.Acts.User]
        ],
        has_many: [
          revisions: [module: Resolvinator.Content.AnswerRevision]
        ]
      ]
    ]

  def changeset(answer, attrs) do
    answer
    |> base_changeset(attrs)
    |> cast(attrs, [:answer_type, :is_accepted, :references, :code_snippets, :question_id])
    |> validate_required([:question_id])
    |> validate_inclusion(:answer_type, ~w(explanation solution workaround reference))
    |> foreign_key_constraint(:question_id)
    |> validate_code_snippets()
  end

  defp validate_code_snippets(changeset) do
    case get_change(changeset, :code_snippets) do
      nil -> changeset
      snippets when is_list(snippets) ->
        validate_each_snippet(changeset, snippets)
      _ ->
        add_error(changeset, :code_snippets, "must be a list of code snippets")
    end
  end

  defp validate_each_snippet(changeset, snippets) do
    valid_snippets = Enum.all?(snippets, &valid_snippet?/1)
    if valid_snippets do
      changeset
    else
      add_error(changeset, :code_snippets, "contains invalid code snippets")
    end
  end

  defp valid_snippet?(%{"code" => code, "language" => lang}) when is_binary(code) and is_binary(lang), do: true
  defp valid_snippet?(_), do: false
end
