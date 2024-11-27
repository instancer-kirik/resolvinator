defmodule Resolvinator.Repo.Migrations.CreateMitigations do
  use Ecto.Migration

  def change do
    create table(:mitigations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text, null: false
      add :strategy, :string, null: false
      add :status, :string, default: "not_started", null: false
      add :effectiveness, :string
      add :cost, :decimal
      add :start_date, :date
      add :target_date, :date
      add :completion_date, :date
      add :notes, :text
      add :risk_id, references(:risks, on_delete: :delete_all), null: false
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:mitigations, [:risk_id])
    create index(:mitigations, [:creator_id])
  end
end
