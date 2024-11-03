defmodule ResolvinatorWeb.API.AllocationJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.{RiskJSON, MitigationJSON, UserJSON}

  def data(allocation, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: allocation.id,
      type: "allocation",
      attributes: %{
        name: allocation.name,
        type: allocation.type,
        amount: allocation.amount,
        quantity: allocation.quantity,
        unit: allocation.unit,
        start_date: allocation.start_date,
        end_date: allocation.end_date,
        status: allocation.status,
        notes: allocation.notes,
        allocated_at: allocation.allocated_at,
        inserted_at: allocation.inserted_at,
        updated_at: allocation.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("risk", allocation.risk, &RiskJSON.data/1, includes)
    |> maybe_add_relationship("mitigation", allocation.mitigation, &MitigationJSON.data/1, includes)
    |> maybe_add_relationship("creator", allocation.creator, &UserJSON.reference_data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end 