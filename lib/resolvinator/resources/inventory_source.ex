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
    field :notes, :string
    
    belongs_to :inventory_item, Resolvinator.Resources.InventoryItem
    belongs_to :supplier, Resolvinator.Suppliers.Supplier

    timestamps(type: :utc_datetime)
  end 

  @doc false
  def changeset(inventory_source, attrs) do
    inventory_source
    |> cast(attrs, [
      :source_type, :source_item_id, :source_item_url, 
      :unit_price, :currency, :minimum_quantity, 
      :maximum_quantity, :lead_time_days, :availability_status,
      :last_checked_at, :auto_order_enabled, :auto_order_threshold,
      :preferred_source, :metadata, :notes,
      :inventory_item_id, :supplier_id
    ])
    |> validate_required([
      :source_type, :unit_price, :currency,
      :availability_status, :inventory_item_id
    ])
    |> validate_inclusion(:source_type, ["supplier", "marketplace", "internal"])
    |> foreign_key_constraint(:inventory_item_id)
    |> foreign_key_constraint(:supplier_id)
  end
end 