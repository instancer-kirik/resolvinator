defmodule Resolvinator.Content.Advantage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "advantages" do
    field :name, :string
    field :desc, :string
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    field :status, :string, default: "initial"
    field :rejection_reason, :string

    belongs_to :user, Resolvinator.Accounts.User
    many_to_many :related_advantages, __MODULE__,
    join_through: "advantage_relationships",
    join_keys: [advantage_id: :id, related_advantage_id: :id]
    many_to_many :lessons, Resolvinator.Content.Lesson, join_through: "lesson_advantage_relationships"
    many_to_many :problems, Resolvinator.Content.Problem, join_through: "problem_advantage_relationships"
    many_to_many :solutions, Resolvinator.Content.Solution, join_through: "solution_advantage_relationships"
    many_to_many :descriptions, Resolvinator.Content.Description, join_through: "advantage_descriptions"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(advantage, attrs) do
    advantage
    |> cast(attrs, [:name, :desc, :user_id, :upvotes, :downvotes])
    |> validate_required([:name, :desc])
  end
end
defmodule Resolvinator.Content.AdvantageDescription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "advantage_descriptions" do
    belongs_to :advantage, Resolvinator.Content.Advantage
    belongs_to :description, Resolvinator.Content.Description

    timestamps()
  end

  @doc false
  def changeset(advantage_description, attrs) do
    advantage_description
    |> cast(attrs, [:advantage_id, :description_id])
    |> validate_required([:advantage_id, :description_id])
    |> unique_constraint([:advantage_id, :description_id])
  end
end
