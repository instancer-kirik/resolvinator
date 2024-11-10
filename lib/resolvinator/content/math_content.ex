defmodule Resolvinator.Content.MathContent do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> validate_required([:latex])
    |> validate_proof_structure()
    |> validate_latex()
  end

  defp validate_latex(changeset) do
    case get_change(changeset, :latex) do
      nil -> changeset
      latex ->
        if valid_latex?(latex), do: changeset, else: add_error(changeset, :latex, "invalid LaTeX syntax")
    end
  end

  defp valid_latex?(latex) do
    balanced_delimiters?(latex, ["\\(", "\\)"], ["$$", "$$"], ["\\[", "\\]"])
  end

  defp balanced_delimiters?(text, delim1, delim2, delim3) do
    check_delimiters(text, delim1) and
    check_delimiters(text, delim2) and
    check_delimiters(text, delim3)
  end

  defp check_delimiters(text, [open, close]) do
    open_count = String.split(text, open) |> length |> Kernel.-(1)
    close_count = String.split(text, close) |> length |> Kernel.-(1)
    open_count == close_count
  end

  defp validate_proof_structure(changeset) do
    case get_change(changeset, :proof_type) do
      nil -> changeset
      proof_type ->
        validate_proof_type(changeset, proof_type)
    end
  end

  defp validate_proof_type(changeset, proof_type) do
    case proof_type do
      "direct" ->
        changeset
        |> validate_required([:assumptions, :steps, :conclusion])
        |> validate_steps_structure()

      "contradiction" ->
        changeset
        |> validate_required([:assumptions, :steps, :conclusion])
        |> validate_contradiction_structure()

      "induction" ->
        changeset
        |> validate_required([:assumptions, :steps, :conclusion])
        |> validate_induction_structure()

      _ ->
        add_error(changeset, :proof_type, "must be one of: direct, contradiction, induction")
    end
  end

  defp validate_steps_structure(changeset) do
    case get_change(changeset, :steps) do
      nil -> changeset
      steps when is_list(steps) ->
        if Enum.all?(steps, &valid_step?/1) do
          changeset
        else
          add_error(changeset, :steps, "contains invalid step structure")
        end
      _ ->
        add_error(changeset, :steps, "must be a list of steps")
    end
  end

  defp validate_contradiction_structure(changeset) do
    case get_change(changeset, :steps) do
      nil -> changeset
      steps when is_list(steps) ->
        if has_contradiction?(steps) do
          changeset
        else
          add_error(changeset, :steps, "must lead to a contradiction")
        end
      _ ->
        add_error(changeset, :steps, "must be a list of steps")
    end
  end

  defp validate_induction_structure(changeset) do
    case get_change(changeset, :steps) do
      nil -> changeset
      steps when is_list(steps) ->
        if has_base_and_inductive_cases?(steps) do
          changeset
        else
          add_error(changeset, :steps, "must include base case and inductive step")
        end
      _ ->
        add_error(changeset, :steps, "must be a list of steps")
    end
  end

  defp valid_step?(%{"statement" => statement, "justification" => justification})
    when is_binary(statement) and is_binary(justification), do: true
  defp valid_step?(_), do: false

  defp has_contradiction?(steps) do
    Enum.any?(steps, fn
      %{"statement" => statement} -> String.contains?(statement, "contradiction") or
                                   String.contains?(statement, "⊥")
      _ -> false
    end)
  end

  defp has_base_and_inductive_cases?(steps) do
    has_base = Enum.any?(steps, fn
      %{"type" => "base_case"} -> true
      _ -> false
    end)

    has_inductive = Enum.any?(steps, fn
      %{"type" => "inductive_step"} -> true
      _ -> false
    end)

    has_base and has_inductive
  end
end
