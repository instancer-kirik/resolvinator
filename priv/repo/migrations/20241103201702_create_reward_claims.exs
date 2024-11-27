defmodule Resolvinator.Repo.Migrations.CreateRewardClaims do
  use Ecto.Migration

  def change do
    create table(:reward_claims, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, null: false, default: "pending"
      add :evidence, :map
      add :reviewed_at, :utc_datetime
      add :reward_id, references(:rewards, on_delete: :delete_all), null: false
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id, null: false
      # Note: reviewed_by_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :reviewed_by_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:reward_claims, [:reward_id])
    create index(:reward_claims, [:user_id])
    create index(:reward_claims, [:reviewed_by_id])
    create index(:reward_claims, [:status])
    create unique_index(:reward_claims, [:reward_id, :user_id])
  end
end
