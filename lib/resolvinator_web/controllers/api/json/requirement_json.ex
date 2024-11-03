defmodule ResolvinatorWeb.API.RequirementJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.{
    ProjectJSON,
    RiskJSON,
    MitigationJSON,
    ActorJSON,
    UserJSON,
    InventoryJSON
  }

  def index(%{requirements: requirements}) do
    %{data: for(requirement <- requirements, do: data(requirement))}
  end

  def show(%{requirement: requirement}) do
    %{data: data(requirement)}
  end

  def data(requirement, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: requirement.id,
      type: "requirement",
      attributes: %{
        name: requirement.name,
        description: requirement.description,
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
    |> maybe_add_relationship("project", requirement.project, &ProjectJSON.reference_data/1, includes)
    |> maybe_add_relationship("risk", requirement.risk, &RiskJSON.reference_data/1, includes)
    |> maybe_add_relationship("mitigation", requirement.mitigation, &MitigationJSON.reference_data/1, includes)
    |> maybe_add_relationship("responsible_actor", requirement.responsible_actor, &ActorJSON.reference_data/1, includes)
    |> maybe_add_relationship("creator", requirement.creator, &UserJSON.reference_data/1, includes)
    |> maybe_add_relationship("inventory_item", requirement.inventory_item, &InventoryJSON.reference_data/1, includes)

    Map.put(base, :relationships, relationships)
  end

  @doc """
  Minimal requirement data for relationships
  """
  def reference_data(requirement) do
    %{
      id: requirement.id,
      type: "requirement",
      attributes: %{
        name: requirement.name,
        status: requirement.status
      }
    }
  end
end 