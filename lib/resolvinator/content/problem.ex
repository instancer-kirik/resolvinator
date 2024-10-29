defmodule Resolvinator.Content.Problem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "problems" do
    field :name, :string
    field :desc, :string
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    field :status, :string, default: "initial"
    field :rejection_reason, :string

    belongs_to :user, Resolvinator.Accounts.User
    many_to_many :related_problems, __MODULE__,
    join_through: "problem_relationships",
    join_keys: [problem_id: :id, related_problem_id: :id]
    many_to_many :lessons, Resolvinator.Content.Lesson, join_through: "problem_lesson_relationships"
    many_to_many :advantages, Resolvinator.Content.Advantage, join_through: "problem_advantage_relationships"
    many_to_many :solutions, Resolvinator.Content.Solution, join_through: "problem_solution_relationships"
    many_to_many :descriptions, Resolvinator.Content.Description, join_through: "problem_descriptions"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(problem, attrs) do
    problem
    |> cast(attrs, [:name, :desc, :user_id,  :upvotes, :downvotes])
    |> validate_required([:name, :desc])
  end
end
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
  end
end
