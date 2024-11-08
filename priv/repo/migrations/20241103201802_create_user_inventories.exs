defmodule Resolvinator.Repo.Migrations.CreateUserInventories do
  use Ecto.Migration

  def change do
    create table(:user_inventories) do
      add :quantity, :decimal, null: false
      add :status, :string, default: "active"
      add :metadata, :map, default: %{}
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :inventory_item_id, references(:inventory_items, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_inventories, [:user_id])
    create index(:user_inventories, [:inventory_item_id])
    create unique_index(:user_inventories, [:user_id, :inventory_item_id])
  end
end
