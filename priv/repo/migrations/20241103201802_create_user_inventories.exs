defmodule Resolvinator.Repo.Migrations.CreateUserInventories do
  use Ecto.Migration

  def change do
    create table(:user_inventories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :decimal, null: false
      add :status, :string, default: "active"
      add :metadata, :map, default: %{}
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id, null: false
      add :inventory_item_id, references(:inventory_items, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_inventories, [:user_id])
    create index(:user_inventories, [:inventory_item_id])
    create unique_index(:user_inventories, [:user_id, :inventory_item_id])
  end
end
