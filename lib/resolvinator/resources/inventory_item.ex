defmodule Resolvinator.Resources.InventoryItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_items" do
    field :name, :string
    field :description, :text
    field :category, :string
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
    |> cast(attrs, [
      :name, :description, :category, :sku, :unit,
      :quantity_available, :quantity_allocated, :minimum_stock,
      :reorder_point, :cost_per_unit, :location, :is_consumable,
      :last_restock_date, :next_restock_date, :supplier_info,
      :status, :project_id, :creator_id
    ])
    |> validate_required([
      :name, :category, :quantity_available,
      :minimum_stock, :reorder_point, :status
    ])
    |> validate_number(:quantity_available, greater_than_or_equal_to: 0)
    |> validate_number(:quantity_allocated, greater_than_or_equal_to: 0)
    |> validate_number(:minimum_stock, greater_than: 0)
    |> validate_number(:reorder_point, greater_than: 0)
    |> validate_stock_levels()
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:creator_id)
  end

  defp validate_stock_levels(changeset) do
    quantity_available = get_field(changeset, :quantity_available) || 0
    quantity_allocated = get_field(changeset, :quantity_allocated) || 0
    minimum_stock = get_field(changeset, :minimum_stock) || 0
    reorder_point = get_field(changeset, :reorder_point) || 0

    changeset
    |> validate_number(:reorder_point, greater_than: minimum_stock)
    |> validate_allocation(quantity_available, quantity_allocated)
  end

  defp validate_allocation(changeset, available, allocated) when allocated > available do
    add_error(changeset, :quantity_allocated, "cannot exceed available quantity")
  end
  defp validate_allocation(changeset, _available, _allocated), do: changeset
end 