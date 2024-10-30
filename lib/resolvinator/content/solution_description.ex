defmodule Resolvinator.Content.SolutionDescription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "solution_descriptions" do
    belongs_to :solution, Resolvinator.Content.Solution
    belongs_to :description, Resolvinator.Content.Description

    timestamps()
  end

  @doc false
  def changeset(solution_description, attrs) do
    solution_description
    |> cast(attrs, [:solution_id, :description_id])
    |> validate_required([:solution_id, :description_id])
    |> unique_constraint([:solution_id, :description_id])
    |> foreign_key_constraint(:solution_id)
    |> foreign_key_constraint(:description_id)
  end
end
