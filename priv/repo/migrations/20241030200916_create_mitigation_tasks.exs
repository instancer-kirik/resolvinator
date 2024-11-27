defmodule Resolvinator.Repo.Migrations.CreateMitigationTasks do
  use Ecto.Migration

  def change do
    create table(:mitigation_tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :status, :string, default: "not_started", null: false
      add :due_date, :date
      add :completion_date, :date
      add :mitigation_id, references(:mitigations, on_delete: :delete_all), null: false
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false
      # Note: assignee_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :assignee_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:mitigation_tasks, [:mitigation_id])
    create index(:mitigation_tasks, [:creator_id])
    create index(:mitigation_tasks, [:assignee_id])
  end
end
