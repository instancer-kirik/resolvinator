defmodule Resolvinator.Repo.Migrations.CreateproblemSolutionRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_solution_relationships) do
      add :problem_id, references(:problems, on_delete: :delete_all)
      add :solution_id, references(:solutions, on_delete: :delete_all)
      
    end

    create unique_index(:problem_solution_relationships, [:problem_id, :solution_id])
   #below makes it faster i guess idk
    create index(:problem_solution_relationships, [:problem_id])
    create index(:problem_solution_relationships, [:solution_id])
  end
end
