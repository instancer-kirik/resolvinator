defmodule Resolvinator.Resources.InventoryItems.UserInventory do
  use Flint.Schema
  import Ecto.Changeset

  schema "user_inventories" do
    field :quantity, :integer, default: 0
    field :last_updated, :utc_datetime
    field :notes, :string
    field :metadata, :map, default: %{}

    belongs_to :user, Acts.User
    belongs_to :inventory_item, Resolvinator.Resources.InventoryItems.InventoryItem

    timestamps(type: :utc_datetime)
  end

  def changeset(user_inventory, attrs) do
    user_inventory
    |> cast(attrs, [:quantity, :last_updated, :notes, :metadata, :user_id, :inventory_item_id])
    |> validate_required([:quantity, :last_updated, :user_id, :inventory_item_id])
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:inventory_item_id)
    |> unique_constraint([:user_id, :inventory_item_id])
  end
end
