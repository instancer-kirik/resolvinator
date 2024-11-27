defmodule Resolvinator.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string, null: false
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      add :status, :string, default: "initial"
      add :rejection_reason, :string
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    # Join table for users who "have" the problem
    create table(:user_problems, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id
      add :problem_id, references(:problems, on_delete: :delete_all)
      
      timestamps(type: :utc_datetime)
    end

    create index(:problems, [:creator_id])
    create index(:problems, [:name])
    create unique_index(:user_problems, [:user_id, :problem_id])
  end
end
