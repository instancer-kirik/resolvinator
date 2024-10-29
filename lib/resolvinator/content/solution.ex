defmodule Resolvinator.Content.Solution do
  use Ecto.Schema
  import Ecto.Changeset

  schema "solutions" do
    field :name, :string
    field :desc, :string
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    field :status, :string, default: "initial"
    field :rejection_reason, :string

    belongs_to :user, Resolvinator.Accounts.User
    many_to_many :related_solutions, __MODULE__,
    join_through: "solution_relationships",
    join_keys: [solution_id: :id, related_solution_id: :id]
    many_to_many :lessons, Resolvinator.Content.Lesson, join_through: "lesson_solution_relationships"
    many_to_many :advantages, Resolvinator.Content.Advantage, join_through: "solution_advantage_relationships"
    many_to_many :problems, Resolvinator.Content.Problem, join_through: "problem_solution_relationships"
    many_to_many :descriptions, Resolvinator.Content.Description, join_through: "solution_descriptions"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(solution, attrs) do
    solution
    |> cast(attrs, [:name, :desc, :user_id, :upvotes, :downvotes])
    |> validate_required([:name, :desc])
  end
end
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
  end
end
