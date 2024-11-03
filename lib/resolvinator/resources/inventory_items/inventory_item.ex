defmodule Resolvinator.Resources.InventoryItems.InventoryItem do

  import Ecto.Changeset
  import Ecto.Query

  use Resolvinator.Resources.InventoryBehavior,
    type_name: :inventory_item,
    table_name: "inventory_items",
    additional_schema: [
      fields: [
        sku: :string,
        unit: :string,
        quantity_available: {:integer, default: 0},
        quantity_allocated: {:integer, default: 0},
        minimum_stock: :integer,
        reorder_point: :integer,
        cost_per_unit: :decimal,
        location: :string,
        is_consumable: {:boolean, default: false},
        last_restock_date: :date,
        next_restock_date: :date,
        supplier_info: :map
      ],
      relationships: [
        many_to_many: [
          users: [
            module: Resolvinator.Accounts.User,
            join_through: "user_inventories",
            join_keys: [inventory_item_id: :id, user_id: :id],
            on_replace: :delete,
            defaults: [
              quantity: 0,
              last_updated: {:datetime, :utc_now}
            ]
          ]
        ],
        has_many: [
          requirements: Resolvinator.Resources.Requirements.Requirement,
          allocations: Resolvinator.Resources.Allocations.Allocation,
          inventory_sources: Resolvinator.Resources.InventorySources.InventorySource
        ]
      ]
    ]

  def changeset(inventory_item, attrs) do
    inventory_item
    |> base_changeset(attrs)
    |> cast(attrs, [
      :sku, :unit, :quantity_available, :quantity_allocated,
      :minimum_stock, :reorder_point, :cost_per_unit, :location,
      :is_consumable, :last_restock_date, :next_restock_date,
      :supplier_info
    ])
    |> validate_number(:quantity_available, greater_than_or_equal_to: 0)
    |> validate_number(:quantity_allocated, greater_than_or_equal_to: 0)
    |> validate_number(:minimum_stock, greater_than: 0)
    |> validate_number(:reorder_point, greater_than: 0)
    |> validate_stock_levels()
  end

  defp validate_stock_levels(changeset) do
    quantity_available = get_field(changeset, :quantity_available) || 0
    quantity_allocated = get_field(changeset, :quantity_allocated) || 0
    minimum_stock = get_field(changeset, :minimum_stock) || 0
    _reorder_point = get_field(changeset, :reorder_point) || 0

    changeset
    |> validate_number(:reorder_point, greater_than: minimum_stock)
    |> validate_allocation(quantity_available, quantity_allocated)
  end

  defp validate_allocation(changeset, available, allocated) when allocated > available do
    add_error(changeset, :quantity_allocated, "cannot exceed available quantity")
  end
  defp validate_allocation(changeset, _available, _allocated), do: changeset
end
