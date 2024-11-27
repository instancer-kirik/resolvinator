defmodule Resolvinator.Repo.Migrations.ConvertUserSchedulingPreferencesToBinaryId do
  use Ecto.Migration

  def up do
    # Drop existing indexes and foreign keys
    drop_if_exists index(:user_scheduling_preferences, [:user_id])
    execute "ALTER TABLE user_scheduling_preferences DROP CONSTRAINT IF EXISTS user_scheduling_preferences_user_id_fkey"

    # Drop the existing primary key
    execute "ALTER TABLE user_scheduling_preferences DROP CONSTRAINT IF EXISTS user_scheduling_preferences_pkey"

    # Convert id to binary_id
    alter table(:user_scheduling_preferences) do
      remove :id
      add :id, :binary_id, primary_key: true
    end

    # Recreate the foreign key and index
    alter table(:user_scheduling_preferences) do
      # Note:  references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :, :binary_id, null: false
    end
    create unique_index(:user_scheduling_preferences, [:user_id])
  end

  def down do
    # This is a destructive change, so down migration is not supported
    raise Ecto.MigrationError, message: "Cannot revert this migration - binary_id to bigint conversion would lose data"
  end
end
