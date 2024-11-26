defmodule Resolvinator.Repo.Migrations.CreateproblemproblemRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :problem_id, references(:problems, type: :binary_id, on_delete: :delete_all), null: false
      add :related_problem_id, references(:problems, type: :binary_id, on_delete: :delete_all), null: false
     
      timestamps(type: :utc_datetime)
    end

    create unique_index(:problem_relationships, [:problem_id, :related_problem_id])
    create index(:problem_relationships, [:problem_id])
    create index(:problem_relationships, [:related_problem_id])
  end
end
