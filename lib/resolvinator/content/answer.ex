defmodule Resolvinator.Content.Answer do
  use Flint.Schema
  use Resolvinator.Content.ContentBehavior,
    type_name: "answer",
    table_name: "answers",
    relationship_table: "answer_relationships",
    description_table: "answer_descriptions"

  schema_field do
    field :answer_type, :string
    field :is_accepted, :boolean, default: false
    field :references, {:array, :string}, default: []
    field :code_snippets, {:array, :map}, default: []

    belongs_to :question, Resolvinator.Content.Question

    # Track answer revisions
    has_many :revisions, Resolvinator.Content.AnswerRevision
  end

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
