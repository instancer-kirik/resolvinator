defmodule Resolvinator.Repo.Migrations.CreateContentRelationshipTables do
  use Ecto.Migration

  def change do
    # Create join tables if they don't exist
    create_if_not_exists table(:lesson_relationships) do
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      add :related_lesson_id, references(:lessons, on_delete: :delete_all)
      timestamps()
    end

    create_if_not_exists table(:advantage_relationships) do
      add :advantage_id, references(:advantages, on_delete: :delete_all)
      add :related_advantage_id, references(:advantages, on_delete: :delete_all)
      timestamps()
    end

    create_if_not_exists table(:solution_relationships) do
      add :solution_id, references(:solutions, on_delete: :delete_all)
      add :related_solution_id, references(:solutions, on_delete: :delete_all)
      timestamps()
    end

    # Add unique indexes
    create_if_not_exists unique_index(:lesson_relationships, [:lesson_id, :related_lesson_id])
    create_if_not_exists unique_index(:advantage_relationships, [:advantage_id, :related_advantage_id])
    create_if_not_exists unique_index(:solution_relationships, [:solution_id, :related_solution_id])
  end
end
