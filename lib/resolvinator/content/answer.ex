defmodule Resolvinator.Content.Answer do
  use Flint.Schema
  alias Flint.Schema
  import Ecto.Changeset
  import Ecto.Query

  use Resolvinator.Content.ContentBehavior,
    type_name: :answer,
    table_name: "answers",
    relationship_table: "answer_relationships",
    description_table: "answer_descriptions",
    relationship_keys: [answer_id: :id, related_answer_id: :id],
    description_keys: [answer_id: :id, description_id: :id],
    additional_schema: [
      fields: [
        answer_type: :string,
        is_accepted: {:boolean, default: false},
        references: {{:array, :string}, default: []},
        code_snippets: {{:array, :map}, default: []}
      ],
      relationships: [
        belongs_to: [
          question: [
            module: Resolvinator.Content.Question
          ]
        ],
        has_many: [
          revisions: [
            module: Resolvinator.Content.AnswerRevision
          ]
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
      snippets ->
        if Enum.all?(snippets, &valid_code_snippet?/1) do
          changeset
        else
          add_error(changeset, :code_snippets, "contains invalid code snippet format")
        end
    end
  end

  defp valid_code_snippet?(%{"language" => lang, "code" => code}) when is_binary(code) do
    lang in ~w(elixir javascript python ruby java cpp csharp sql)
  end
  defp valid_code_snippet?(_), do: false
end
