defmodule Resolvinator.Repo.Migrations.CreateImpacts do
  use Ecto.Migration

  def change do
    create table(:impacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :description, :text
      add :area, :string, null: false
      add :severity, :string, null: false
      add :likelihood, :string
      add :estimated_cost, :decimal
      add :timeframe, :string
      add :notes, :text
      add :risk_id, references(:risks, on_delete: :delete_all), null: false
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:impacts, [:risk_id])
    create index(:impacts, [:creator_id])
  end
end
