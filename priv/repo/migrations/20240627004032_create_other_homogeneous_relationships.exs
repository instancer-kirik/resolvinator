defmodule Resolvinator.Repo.Migrations.CreateOtherHomogeneousRelationships do

    use Ecto.Migration

    def change do
      create table(:solution_relationships) do
        add :solution_id, references(:solutions, on_delete: :delete_all)
        add :related_solution_id, references(:solutions, on_delete: :delete_all)

      end

      create unique_index(:solution_relationships, [:solution_id, :related_solution_id])

      create table(:lesson_relationships) do
        add :lesson_id, references(:lessons, on_delete: :delete_all)
        add :related_lesson_id, references(:lessons, on_delete: :delete_all)

      end

      create unique_index(:lesson_relationships, [:lesson_id, :related_lesson_id])
   
      create table(:advantage_relationships) do
        add :advantage_id, references(:advantages, on_delete: :delete_all)
        add :related_advantage_id, references(:advantages, on_delete: :delete_all)

      end

      create unique_index(:advantage_relationships, [:advantage_id, :related_advantage_id])
    end
end
