defmodule Resolvinator.Repo.Migrations.CreateproblemSolutionRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_solution_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :problem_id, references(:problems, type: :binary_id, on_delete: :delete_all), null: false
      add :solution_id, references(:solutions, type: :binary_id, on_delete: :delete_all), null: false
      
      timestamps(type: :utc_datetime)
    end

    create unique_index(:problem_solution_relationships, [:problem_id, :solution_id])
    create index(:problem_solution_relationships, [:problem_id])
    create index(:problem_solution_relationships, [:solution_id])
  end
end
