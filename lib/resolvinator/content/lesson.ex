defmodule Resolvinator.Content.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lessons" do
    field :name, :string
    field :desc, :string
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    field :status, :string, default: "initial"
    field :rejection_reason, :string
    many_to_many :related_lessons, __MODULE__,
    join_through: "lesson_relationships",
    join_keys: [lesson_id: :id, related_lesson_id: :id]
    many_to_many :problems, Resolvinator.Content.Problem, join_through: "problem_lesson_relationships"
    many_to_many :solutions, Resolvinator.Content.Solution, join_through: "lesson_solution_relationships"
    many_to_many :advantages, Resolvinator.Content.Advantage, join_through: "lesson_advantage_relationships"
    belongs_to :user, Resolvinator.Accounts.User
    many_to_many :descriptions, Resolvinator.Content.Description, join_through: "lesson_descriptions"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [:name, :desc, :user_id, :upvotes, :downvotes])
    |> validate_required([:name, :desc])
  end
end
defmodule Resolvinator.Content.LessonDescription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lesson_descriptions" do
    belongs_to :lesson, Resolvinator.Content.Lesson
    belongs_to :description, Resolvinator.Content.Description

    timestamps()
  end

  @doc false
  def changeset(lesson_description, attrs) do
    lesson_description
    |> cast(attrs, [:lesson_id, :description_id])
    |> validate_required([:lesson_id, :description_id])
    |> unique_constraint([:lesson_id, :description_id])
  end
end
