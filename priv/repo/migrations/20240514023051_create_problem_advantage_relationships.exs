defmodule Resolvinator.Repo.Migrations.CreateproblemadvantageRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_advantage_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :problem_id, references(:problems, type: :binary_id, on_delete: :delete_all), null: false
      add :advantage_id, references(:advantages, type: :binary_id, on_delete: :delete_all), null: false
     
      timestamps(type: :utc_datetime)
    end

    create unique_index(:problem_advantage_relationships, [:problem_id, :advantage_id])
    create index(:problem_advantage_relationships, [:problem_id])
    create index(:problem_advantage_relationships, [:advantage_id])
  end
end
