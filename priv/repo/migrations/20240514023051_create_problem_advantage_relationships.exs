defmodule Resolvinator.Repo.Migrations.CreateproblemadvantageRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_advantage_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :problem_id, references(:problems, on_delete: :delete_all)
      add :advantage_id, references(:advantages, on_delete: :delete_all)
     
    end

    create unique_index(:problem_advantage_relationships, [:problem_id, :advantage_id])
  end
end
