defmodule Resolvinator.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons, primary_key: false) do
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

    # Join table for users who "learned" the lesson
    create table(:user_lessons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      
      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:creator_id])
    create index(:lessons, [:name])
    create unique_index(:user_lessons, [:user_id, :lesson_id])
  end
end
