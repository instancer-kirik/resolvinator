defmodule Resolvinator.Resources.InventoryItem do
  use Resolvinator.Content.ContentBehavior,
    type_name: :inventory_item,
    table_name: "inventory_items",
    relationship_table: "inventory_relationships",
    relationship_keys: [inventory_id: :id, related_inventory_id: :id],
    description_table: "inventory_descriptions"

  # Additional fields specific to inventory
  schema "inventory_items" do
    field :sku, :string
    field :unit, :string
    field :quantity_available, :integer, default: 0
    field :quantity_allocated, :integer, default: 0
    field :minimum_stock, :integer
    field :reorder_point, :integer
    field :cost_per_unit, :decimal
    field :location, :string
    field :is_consumable, :boolean, default: false
    field :last_restock_date, :date
    field :next_restock_date, :date
    field :supplier_info, :map
    field :status, :string, default: "active"

    has_many :requirements, Resolvinator.Resources.Requirement
    has_many :allocations, Resolvinator.Resources.Allocation
    belongs_to :project, Resolvinator.Projects.Project
    belongs_to :creator, Resolvinator.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(inventory_item, attrs) do
    inventory_item
    |> super(attrs)  # Call ContentBehavior's changeset
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