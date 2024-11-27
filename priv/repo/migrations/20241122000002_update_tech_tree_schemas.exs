defmodule Resolvinator.Repo.Migrations.CreateTechTreeTables do
  use Ecto.Migration

  def change do
    # Update tech_items table
    alter table(:tech_items) do
      # Add any missing foreign key constraints
      # Note:  references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :, :binary_id
      # Note:  references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :, :binary_id
      # Note:  references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :, :binary_id
      modify :search_vector, :tsvector
    end

    # Update tech_documentation table
    alter table(:tech_documentation) do
      # Note:  references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :, :binary_id
      # Note:  references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :, :binary_id
      modify :search_vector, :tsvector
    end

    # Update tech_parts table
    alter table(:tech_parts) do
      modify :search_vector, :tsvector
    end

    # Update tech_kits table
    alter table(:tech_kits) do
      modify :search_vector, :tsvector
    end

    # Update tech_item_activities table
    alter table(:tech_item_activities) do
      # Note:  references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :, :binary_id
    end

    # Create indexes for search vectors
    create index(:tech_items, [:search_vector], using: :gin)
    create index(:tech_documentation, [:search_vector], using: :gin)
    create index(:tech_parts, [:search_vector], using: :gin)
    create index(:tech_kits, [:search_vector], using: :gin)
  end
end
