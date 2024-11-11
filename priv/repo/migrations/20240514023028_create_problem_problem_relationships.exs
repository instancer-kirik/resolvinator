defmodule Resolvinator.Repo.Migrations.CreateproblemproblemRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :problem_id, references(:problems, on_delete: :delete_all)
      add :related_problem_id, references(:problems, on_delete: :delete_all)
     
    end

    create unique_index(:problem_relationships, [:problem_id, :related_problem_id])
  end
end
