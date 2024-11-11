defmodule Resolvinator.Repo.Migrations.AddProblemRiskRelationships do
  use Ecto.Migration

  def change do
    create table(:problem_risk_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :problem_id, references(:problems, type: :binary_id, on_delete: :delete_all), null: false
      add :risk_id, references(:risks, type: :binary_id, on_delete: :delete_all), null: false
      add :relationship_type, :string
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:problem_risk_relationships, [:problem_id])
    create index(:problem_risk_relationships, [:risk_id])
    create unique_index(:problem_risk_relationships, [:problem_id, :risk_id])
  end
end 