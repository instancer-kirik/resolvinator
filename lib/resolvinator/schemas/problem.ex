defmodule Resolvinator.Problem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "problems" do
    field :name, :string
    field :desc, :string
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    belongs_to :author, Resolvinator.Author
    many_to_many :solutions, Resolvinator.Solution, join_through: "problems_solutions"
    many_to_many :advantages, Resolvinator.Advantage, join_through: "problems_advantages"

    timestamps()
  end

  def changeset(problem, attrs) do
    problem
    |> cast(attrs, [:name, :desc, :upvotes, :downvotes])
    |> validate_required([:name, :desc])
  end
end
