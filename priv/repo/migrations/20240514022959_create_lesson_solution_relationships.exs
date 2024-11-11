defmodule Resolvinator.Repo.Migrations.CreateLessonSolutionRelationships do
  use Ecto.Migration

  def change do
    create table(:lesson_solution_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      add :solution_id, references(:solutions, on_delete: :delete_all)
    
    end

    create unique_index(:lesson_solution_relationships, [:lesson_id, :solution_id])
  end
end
