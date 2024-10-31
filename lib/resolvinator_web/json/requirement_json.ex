defmodule ResolvinatorWeb.RequirementJSON do
  import ResolvinatorWeb.JSONHelpers

  def data(requirement, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: requirement.id,
      type: "requirement",
      attributes: %{
        name: requirement.name,
        type: requirement.type,
        priority: requirement.priority,
        estimated_amount: requirement.estimated_amount,
        unit: requirement.unit,
        needed_by_date: requirement.needed_by_date,
        duration_days: requirement.duration_days,
        status: requirement.status,
        justification: requirement.justification,
        notes: requirement.notes,
        quantity_needed: requirement.quantity_needed,
        quantity_allocated: requirement.quantity_allocated,
        reorder_threshold: requirement.reorder_threshold,
        is_consumable: requirement.is_consumable,
        inserted_at: requirement.inserted_at,
        updated_at: requirement.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("project", requirement.project, &ProjectJSON.data/1, includes)
    |> maybe_add_relationship("risk", requirement.risk, &RiskJSON.data/1, includes)
    |> maybe_add_relationship("mitigation", requirement.mitigation, &MitigationJSON.data/1, includes)
    |> maybe_add_relationship("responsible_actor", requirement.responsible_actor, &ActorJSON.data/1, includes)
    |> maybe_add_relationship("creator", requirement.creator, &user_data/1, includes)
    |> maybe_add_relationship("inventory_item", requirement.inventory_item, &InventoryJSON.data/1, includes)

    Map.put(base, :relationships, relationships)
  end   
end 