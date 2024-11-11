defmodule Resolvinator.Repo.Migrations.AddSolutionMitigationRelationships do
  use Ecto.Migration

  def change do
    create table(:solution_mitigation_links, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :solution_id, references(:solutions, type: :binary_id, on_delete: :delete_all), null: false
      add :mitigation_id, references(:mitigations, on_delete: :delete_all), null: false
      add :relationship_type, :string
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:solution_mitigation_links, [:solution_id])
    create index(:solution_mitigation_links, [:mitigation_id])
    create unique_index(:solution_mitigation_links, [:solution_id, :mitigation_id])
  end
end
