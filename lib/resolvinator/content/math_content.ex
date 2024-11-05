defmodule Resolvinator.Content.MathContent do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :latex, :string
    field :proof_type, :string  # direct, contradiction, induction, etc.
    field :assumptions, {:array, :string}
    field :steps, {:array, :map}  # Structured proof steps
    field :conclusion, :string
    field :notation_used, {:array, :string}
    field :visualization_type, :string  # graph, diagram, plot
  end

  def changeset(math_content, attrs) do
    math_content
    |> cast(attrs, [:latex, :proof_type, :assumptions, :steps, :conclusion, :notation_used, :visualization_type])
    |> validate_latex()
    |> validate_proof_structure()
  end

  defp validate_latex(changeset) do
    case get_change(changeset, :latex) do
      nil -> changeset
      latex ->
        if valid_latex?(latex), do: changeset, else: add_error(changeset, :latex, "invalid LaTeX syntax")
    end
  end

  defp valid_latex?(latex) do
    # Basic LaTeX validation - could be enhanced with a proper parser
    balanced_delimiters?(latex, ["\\(", "\\)"], ["$$", "$$"], ["\\[", "\\]"])
  end
end
