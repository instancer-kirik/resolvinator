defmodule Resolvinator.Repo.Migrations.CreateFilesystemEntries do
  use Ecto.Migration

  def change do
    create table(:filesystem_entries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :path, :string, null: false
      add :entry_type, :string, null: false
      add :size, :bigint
      add :permissions, :string
      add :owner, :string
      add :group, :string
      add :last_accessed, :utc_datetime
      add :last_modified, :utc_datetime
      add :checksum, :string
      add :metadata, :map, default: %{}

      add :system_id, references(:systems, type: :binary_id), null: false
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id
      add :parent_id, references(:filesystem_entries, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:filesystem_entries, [:system_id])
    create index(:filesystem_entries, [:creator_id])
    create index(:filesystem_entries, [:parent_id])
    create unique_index(:filesystem_entries, [:system_id, :path])
  end
end
