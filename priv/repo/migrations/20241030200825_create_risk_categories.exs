defmodule Resolvinator.Repo.Migrations.CreateRiskCategories do
  use Ecto.Migration

  def change do
    create table(:risk_categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :color, :string
      add :assessment_criteria, :map, default: %{}
      # Note: creator_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false
      add :project_id, references(:projects, type: :binary_id, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:risk_categories, [:creator_id])
    create index(:risk_categories, [:project_id])
    create unique_index(:risk_categories, [:name, :project_id])
  end
end
