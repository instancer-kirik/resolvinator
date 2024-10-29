defmodule Resolvinator.Repo.Migrations.CreateproblemproblemRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_relationships) do
      add :problem_id, references(:problems, on_delete: :delete_all)
      add :related_problem_id, references(:problems, on_delete: :delete_all)
     
    end

    create unique_index(:problem_relationships, [:problem_id, :related_problem_id])
  end
end
