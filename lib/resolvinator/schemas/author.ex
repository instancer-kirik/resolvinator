defmodule Resolvinator.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :username, :string
    field :email, :string

    has_many :problems, Resolvinator.Problem
    has_many :solutions, Resolvinator.Solution
    has_many :advantages, Resolvinator.Advantage

    timestamps()
  end

  def changeset(author, attrs) do
    author
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
  end
end
