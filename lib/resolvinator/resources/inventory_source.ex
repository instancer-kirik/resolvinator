defmodule Resolvinator.Resources.InventorySource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_sources" do
    field :source_type, :string  # "supplier", "marketplace", "internal"
    field :source_item_id, :string
    field :source_item_url, :string
    field :unit_price, :decimal
    field :currency, :string
    field :minimum_quantity, :integer
    field :maximum_quantity, :integer
    field :lead_time_days, :integer
    field :availability_status, :string
    field :last_checked_at, :utc_datetime
    field :auto_order_enabled, :boolean, default: false
    field :auto_order_threshold, :integer
    field :preferred_source, :boolean, default: false
    field :metadata, :map

    belongs_to :inventory_item, Resolvinator.Resources.InventoryItem
    belongs_to :supplier, Resolvinator.Suppliers.Supplier

    timestamps(type: :utc_datetime)
  end 
end 