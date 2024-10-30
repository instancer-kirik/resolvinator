defmodule Resolvinator.Content.ProblemDescription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "problem_descriptions" do
    belongs_to :problem, Resolvinator.Content.Problem
    belongs_to :description, Resolvinator.Content.Description

    timestamps()
  end

  def changeset(problem_description, attrs) do
    problem_description
    |> cast(attrs, [:problem_id, :description_id])
    |> validate_required([:problem_id, :description_id])
    |> unique_constraint([:problem_id, :description_id])
  end
end
