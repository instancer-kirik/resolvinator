defmodule Resolvinator.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :status, :string, default: "planning", null: false
      add :risk_appetite, :string, null: false
      add :start_date, :date
      add :target_date, :date
      add :completion_date, :date
      add :settings, :map, default: %{}
      # Note: creator_id references resolvinator_acts_fdw.users but we can't use a foreign key
      # constraint because PostgreSQL doesn't support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:creator_id])
    create unique_index(:projects, [:name])
  end

  def down do
    drop table(:projects)
  end
end
