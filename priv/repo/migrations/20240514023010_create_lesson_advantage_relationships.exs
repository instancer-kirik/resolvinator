defmodule Resolvinator.Repo.Migrations.CreateLessonadvantageRelationships do
  use Ecto.Migration

  def change do
    create table(:lesson_advantage_relationships) do
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      add :advantage_id, references(:advantages, on_delete: :delete_all)
    
    end

    create unique_index(:lesson_advantage_relationships, [:lesson_id, :advantage_id])
  end
end
