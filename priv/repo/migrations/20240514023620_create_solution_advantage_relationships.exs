defmodule Resolvinator.Repo.Migrations.CreatesolutionadvantageRelationships do
  use Ecto.Migration

  def change do
    create table(:solution_advantage_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :solution_id, references(:solutions, on_delete: :delete_all)
      add :advantage_id, references(:advantages, on_delete: :delete_all)
     
    end

    create unique_index(:solution_advantage_relationships, [:solution_id, :advantage_id])
  end
end
