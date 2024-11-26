defmodule Resolvinator.Repo.Migrations.CreateTechTreeTables do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"
    execute "CREATE EXTENSION IF NOT EXISTS btree_gin"

    create table(:tech_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :category, :string, null: false
      add :status, :string, null: false
      add :manufacturer, :string
      add :model, :string
      add :serial_number, :string
      add :purchase_date, :date
      add :warranty_expiry, :date
      add :specifications, :map
      add :maintenance_history, {:array, :map}
      add :search_vector, :tsvector
      add :supplier_id, references(:suppliers, type: :binary_id, on_delete: :nilify_all)

      # Note: owner_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :owner_id, :binary_id, null: false

      # Note: assigned_to_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :assigned_to_id, :binary_id

      # Note: last_maintained_by_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :last_maintained_by_id, :binary_id

      timestamps()
    end

    create table(:tech_documentation, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :content, :text
      add :doc_type, :string
      add :version, :string
      add :search_vector, :tsvector
      add :tech_item_id, references(:tech_items, type: :binary_id, on_delete: :delete_all)

      # Note: created_by_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :created_by_id, :binary_id, null: false

      # Note: last_updated_by_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :last_updated_by_id, :binary_id

      timestamps()
    end

    create table(:tech_parts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :part_number, :string
      add :quantity, :integer
      add :unit_cost, :decimal
      add :reorder_point, :integer
      add :location, :string
      add :search_vector, :tsvector
      add :tech_item_id, references(:tech_items, type: :binary_id, on_delete: :nilify_all)

      timestamps()
    end

    create table(:tech_kits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :kit_type, :string
      add :search_vector, :tsvector

      timestamps()
    end

    create table(:tech_item_activities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :activity_type, :string, null: false
      add :description, :text
      add :metadata, :map
      add :tech_item_id, references(:tech_items, type: :binary_id, on_delete: :delete_all)

      # Note: user_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id, null: false

      timestamps()
    end

    # Create indexes for tech_items
    create index(:tech_items, :name)
    create index(:tech_items, :category)
    create index(:tech_items, :status)
    create index(:tech_items, :search_vector, using: "GIN")
    create index(:tech_items, [:owner_id])
    create index(:tech_items, [:assigned_to_id])
    create index(:tech_items, [:last_maintained_by_id])
    create index(:tech_items, [:supplier_id])

    # Create indexes for tech_documentation
    create index(:tech_documentation, :title)
    create index(:tech_documentation, :doc_type)
    create index(:tech_documentation, :search_vector, using: "GIN")
    create index(:tech_documentation, [:tech_item_id])
    create index(:tech_documentation, [:created_by_id])
    create index(:tech_documentation, [:last_updated_by_id])

    # Create indexes for tech_parts
    create index(:tech_parts, :name)
    create index(:tech_parts, :part_number)
    create index(:tech_parts, :search_vector, using: "GIN")
    create index(:tech_parts, [:tech_item_id])

    # Create indexes for tech_kits
    create index(:tech_kits, :name)
    create index(:tech_kits, :kit_type)
    create index(:tech_kits, :search_vector, using: "GIN")

    # Create indexes for tech_item_activities
    create index(:tech_item_activities, :activity_type)
    create index(:tech_item_activities, [:tech_item_id])
    create index(:tech_item_activities, [:user_id])
  end

  def down do
    drop table(:tech_item_activities)
    drop table(:tech_parts)
    drop table(:tech_documentation)
    drop table(:tech_kits)
    drop table(:tech_items)

    execute "DROP EXTENSION IF EXISTS pg_trgm"
    execute "DROP EXTENSION IF EXISTS btree_gin"
  end
end
