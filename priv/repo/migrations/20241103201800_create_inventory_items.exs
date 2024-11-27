defmodule Resolvinator.Repo.Migrations.CreateInventoryItems do
  use Ecto.Migration

  def change do
    create table(:inventory_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :category, :string
      add :status, :string, default: "active"
      add :metadata, :map, default: %{}
      add :notes, :string

      # Inventory specific fields
      add :sku, :string
      add :unit, :string
      add :quantity_available, :integer, default: 0
      add :quantity_allocated, :integer, default: 0
      add :minimum_stock, :integer
      add :reorder_point, :integer
      add :cost_per_unit, :decimal
      add :location, :string
      add :is_consumable, :boolean, default: false
      add :last_restock_date, :date
      add :next_restock_date, :date
      add :supplier_info, :map

      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id
      add :project_id, references(:projects, on_delete: :restrict, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:inventory_items, [:creator_id])
    create index(:inventory_items, [:project_id])
    create index(:inventory_items, [:status])
    create index(:inventory_items, [:sku])
  end
end
