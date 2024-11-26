defmodule Resolvinator.Repo.Migrations.CreateContentRelationshipTables do
  use Ecto.Migration

  def change do
    # Create join tables if they don't exist
    create_if_not_exists table(:lesson_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :lesson_id, references(:lessons, type: :binary_id, on_delete: :delete_all), null: false
      add :related_lesson_id, references(:lessons, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table(:advantage_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :advantage_id, references(:advantages, type: :binary_id, on_delete: :delete_all), null: false
      add :related_advantage_id, references(:advantages, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table(:solution_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :solution_id, references(:solutions, type: :binary_id, on_delete: :delete_all), null: false
      add :related_solution_id, references(:solutions, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    # Create indexes for better query performance
    create_if_not_exists index(:lesson_relationships, [:lesson_id])
    create_if_not_exists index(:lesson_relationships, [:related_lesson_id])
    create_if_not_exists unique_index(:lesson_relationships, [:lesson_id, :related_lesson_id])

    create_if_not_exists index(:advantage_relationships, [:advantage_id])
    create_if_not_exists index(:advantage_relationships, [:related_advantage_id])
    create_if_not_exists unique_index(:advantage_relationships, [:advantage_id, :related_advantage_id])

    create_if_not_exists index(:solution_relationships, [:solution_id])
    create_if_not_exists index(:solution_relationships, [:related_solution_id])
    create_if_not_exists unique_index(:solution_relationships, [:solution_id, :related_solution_id])
  end
end
