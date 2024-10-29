defmodule Resolvinator.Advantage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "advantages" do
    field :name, :string
    field :desc, :string
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    belongs_to :author, Resolvinator.Author
    many_to_many :problems, Resolvinator.Problem, join_through: "problems_advantages"

    timestamps()
  end

  def changeset(advantage, attrs) do
    advantage
    |> cast(attrs, [:name, :desc, :upvotes, :downvotes])
    |> validate_required([:name, :desc])
  end
end
