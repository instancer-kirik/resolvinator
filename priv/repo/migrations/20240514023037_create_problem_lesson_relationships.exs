defmodule Resolvinator.Repo.Migrations.CreateproblemlessonRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_lesson_relationships) do
      add :problem_id, references(:problems, on_delete: :delete_all)
      add :lesson_id, references(:lessons, on_delete: :delete_all)
     
    end

    create unique_index(:problem_lesson_relationships, [:problem_id, :lesson_id])
  end
end
