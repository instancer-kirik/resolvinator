defmodule Resolvinator.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :desc, :string, null: false
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      add :status, :string, default: "initial"
      add :rejection_reason, :string
      add :creator_id, references(:users, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    # Join table for users who "learned" the lesson
    create table(:user_lessons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all)
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      
      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:creator_id])
    create index(:lessons, [:name])
    create unique_index(:user_lessons, [:user_id, :lesson_id])
  end
end
