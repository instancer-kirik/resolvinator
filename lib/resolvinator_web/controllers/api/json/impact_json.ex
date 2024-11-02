defmodule ResolvinatorWeb.ImpactJSON do
  import ResolvinatorWeb.JSONHelpers

  def data(impact, opts \\ []) do
    includes = parse_includes(opts[:includes] || [])
    
    base = %{
      id: impact.id,
      type: "impact",
      attributes: %{
        description: impact.description,
        area: impact.area,
        severity: impact.severity,
        likelihood: impact.likelihood,
        estimated_cost: impact.estimated_cost,
        timeframe: impact.timeframe,
        notes: impact.notes,
        inserted_at: impact.inserted_at,
        updated_at: impact.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("risk", impact.risk, &ResolvinatorWeb.RiskJSON.data/1, includes)
    |> maybe_add_relationship("creator", impact.creator, &user_data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end 