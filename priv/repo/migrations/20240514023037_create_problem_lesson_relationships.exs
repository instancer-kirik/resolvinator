defmodule Resolvinator.Repo.Migrations.CreateproblemlessonRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_lesson_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :problem_id, references(:problems, type: :binary_id, on_delete: :delete_all), null: false
      add :lesson_id, references(:lessons, type: :binary_id, on_delete: :delete_all), null: false
     
      timestamps(type: :utc_datetime)
    end

    create unique_index(:problem_lesson_relationships, [:problem_id, :lesson_id])
    create index(:problem_lesson_relationships, [:problem_id])
    create index(:problem_lesson_relationships, [:lesson_id])
  end
end
