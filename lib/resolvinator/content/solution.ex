defmodule Resolvinator.Content.Solution do
  use Ecto.Schema
  import Ecto.Changeset

  @status_values ~w(initial pending approved rejected)

  schema "solutions" do
    field :name, :string
    field :desc, :string
    field :upvotes, :integer, default: 0
    field :downvotes, :integer, default: 0
    field :status, :string, default: "initial"
    field :rejection_reason, :string

    # Who created the solution
    belongs_to :creator, Resolvinator.Accounts.User, foreign_key: :creator_id
    
    # Who uses this solution
    many_to_many :users_using_solution, Resolvinator.Accounts.User,
      join_through: "user_solutions",
      on_replace: :delete
    
    many_to_many :related_solutions, __MODULE__,
      join_through: "solution_relationships",
      join_keys: [solution_id: :id, related_solution_id: :id]
    
    many_to_many :problems, Resolvinator.Content.Problem,
      join_through: "problem_solution_relationships"
    
    many_to_many :advantages, Resolvinator.Content.Advantage,
      join_through: "solution_advantage_relationships"
    
    many_to_many :descriptions, Resolvinator.Content.Description,
      join_through: "solution_descriptions"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(solution, attrs) do
    solution
    |> cast(attrs, [:name, :desc, :creator_id, :upvotes, :downvotes, :status, :rejection_reason])
    |> validate_required([:name, :desc, :creator_id])
    |> validate_inclusion(:status, @status_values)
    |> foreign_key_constraint(:creator_id)
  end

  @doc """
  Changeset for adding or removing users who use this solution
  """
  def users_using_solution_changeset(solution, users) do
    solution
    |> cast(%{}, [])
    |> put_assoc(:users_using_solution, users)
  end
end
