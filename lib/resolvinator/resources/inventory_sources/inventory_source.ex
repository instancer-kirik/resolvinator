defmodule Resolvinator.Resources.InventorySources.InventorySource do
  import Ecto.Changeset


  use Resolvinator.Resources.InventoryBehavior,
    type_name: :inventory_source,
    table_name: "inventory_sources",
    additional_schema: [
      fields: [
        source_type: :string,
        source_item_id: :string,
        source_item_url: :string,
        unit_price: :decimal,
        currency: :string,
        minimum_quantity: :integer,
        maximum_quantity: :integer,
        lead_time_days: :integer,
        availability_status: :string,
        last_checked_at: :utc_datetime,
        auto_order_enabled: {:boolean, default: false},
        auto_order_threshold: :integer,
        preferred_source: {:boolean, default: false}
      ],
      relationships: [
        belongs_to: [
          inventory_item: Resolvinator.Resources.InventoryItems.InventoryItem,
          supplier: Resolvinator.Suppliers.Supplier
        ]
      ]
    ]

  def changeset(inventory_source, attrs) do
    inventory_source
    |> base_changeset(attrs)
    |> cast(attrs, [
      :source_type, :source_item_id, :source_item_url,
      :unit_price, :currency, :minimum_quantity,
      :maximum_quantity, :lead_time_days, :availability_status,
      :last_checked_at, :auto_order_enabled, :auto_order_threshold,
      :preferred_source, :inventory_item_id, :supplier_id
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
