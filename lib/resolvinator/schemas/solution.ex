defmodule Resolvinator.Solution do
  use Ecto.Schema
  import Ecto.Changeset

  schema "solutions" do
    field :name, :string
    field :desc, :string
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    belongs_to :author, Resolvinator.Author
    many_to_many :problems, Resolvinator.Problem, join_through: "problems_solutions"

    timestamps()
  end

  def changeset(solution, attrs) do
    solution
    |> cast(attrs, [:name, :desc, :upvotes, :downvotes])
    |> validate_required([:name, :desc])
  end
end
