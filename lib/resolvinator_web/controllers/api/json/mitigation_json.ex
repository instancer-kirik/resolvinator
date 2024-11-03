defmodule ResolvinatorWeb.API.MitigationJSON do
  import ResolvinatorWeb.API.JSONHelpers

  def data(mitigation, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])

    base = %{
      id: mitigation.id,
      type: "mitigation",
      attributes: %{
        description: mitigation.description,
        strategy: mitigation.strategy,
        status: mitigation.status,
        effectiveness: mitigation.effectiveness,
        cost: mitigation.cost,
        start_date: mitigation.start_date,
        target_date: mitigation.target_date,
        completion_date: mitigation.completion_date,
        notes: mitigation.notes,
        inserted_at: mitigation.inserted_at,
        updated_at: mitigation.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("risk", mitigation.risk, &ResolvinatorWeb.RiskJSON.data/1, includes)
    |> maybe_add_relationship("tasks", mitigation.tasks, &ResolvinatorWeb.MitigationTaskJSON.data/1, includes)
    |> maybe_add_relationship("creator", mitigation.creator, &ResolvinatorWeb.UserJSON.data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end
