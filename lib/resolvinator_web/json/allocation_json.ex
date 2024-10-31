defmodule ResolvinatorWeb.AllocationJSON do
  import ResolvinatorWeb.JSONHelpers

  def data(allocation, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: allocation.id,
      type: "allocation",
      attributes: %{
        name: allocation.name,
        type: allocation.type,
        amount: allocation.amount,
        unit: allocation.unit,
        start_date: allocation.start_date,
        end_date: allocation.end_date,
        status: allocation.status,
        notes: allocation.notes,
        inserted_at: allocation.inserted_at,
        updated_at: allocation.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("risk", allocation.risk, &ResolvinatorWeb.RiskJSON.data/1, includes)
    |> maybe_add_relationship("mitigation", allocation.mitigation, &ResolvinatorWeb.MitigationJSON.data/1, includes)
    |> maybe_add_relationship("creator", allocation.creator, &user_data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end 