defmodule Resolvinator.Repo.Migrations.CreateSolutions do
  use Ecto.Migration

  def change do
    create table(:solutions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string, null: false
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      add :status, :string, default: "initial"
      add :rejection_reason, :string
      add :creator_id, references(:users, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    # Join table for users who "use" the solution
    create table(:user_solutions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all)
      add :solution_id, references(:solutions, on_delete: :delete_all)
      
      timestamps(type: :utc_datetime)
    end

    create index(:solutions, [:creator_id])
    create index(:solutions, [:name])
    create unique_index(:user_solutions, [:user_id, :solution_id])
  end
end
