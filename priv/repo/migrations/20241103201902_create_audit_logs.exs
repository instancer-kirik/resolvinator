defmodule Resolvinator.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :action, :string, null: false
      add :entity_type, :string, null: false
      add :entity_id, :binary_id, null: false
      add :changes, :map, default: %{}
      add :metadata, :map, default: %{}
      # Note: actor_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :actor_id, :binary_id
      add :project_id, references(:projects, on_delete: :restrict, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:audit_logs, [:entity_id, :entity_type])
    create index(:audit_logs, [:actor_id])
    create index(:audit_logs, [:project_id])
    create index(:audit_logs, [:action])
    create index(:audit_logs, [:inserted_at])
  end
end
