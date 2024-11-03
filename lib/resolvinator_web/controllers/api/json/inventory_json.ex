defmodule ResolvinatorWeb.API.InventoryJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.{ProjectJSON, RequirementJSON, AllocationJSON}

  def data(item, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])

    base = %{
      id: item.id,
      type: "inventory_item",
      attributes: %{
        name: item.name,
        description: item.description,
        category: item.category,
        sku: item.sku,
        unit: item.unit,
        quantity_available: item.quantity_available,
        quantity_allocated: item.quantity_allocated,
        minimum_stock: item.minimum_stock,
        reorder_point: item.reorder_point,
        cost_per_unit: item.cost_per_unit,
        location: item.location,
        is_consumable: item.is_consumable,
        last_restock_date: item.last_restock_date,
        next_restock_date: item.next_restock_date,
        supplier_info: item.supplier_info,
        status: item.status,
        inserted_at: item.inserted_at,
        updated_at: item.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("project", item.project, &ProjectJSON.data/1, includes)
    |> maybe_add_relationship("creator", item.creator, &user_data/1, includes)
    |> maybe_add_relationship("requirements", item.requirements, &RequirementJSON.data/1, includes)
    |> maybe_add_relationship("allocations", item.allocations, &AllocationJSON.data/1, includes)

    Map.put(base, :relationships, relationships)
  end

  defp user_data(user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
