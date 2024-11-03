defmodule ResolvinatorWeb.API.ImpactJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.{RiskJSON, UserJSON}

  def data(impact, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])

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
    |> maybe_add_relationship("risk", impact.risk, &RiskJSON.reference_data/1, includes)
    |> maybe_add_relationship("creator", impact.creator, &UserJSON.reference_data/1, includes)
    |> maybe_add_relationship("affected_actors", impact.affected_actors, &actor_reference/1, includes)

    Map.put(base, :relationships, relationships)
  end

  def reference_data(impact) do
    %{
      id: impact.id,
      type: "impact",
      attributes: %{
        description: impact.description,
        area: impact.area,
        severity: impact.severity
      }
    }
  end

  defp actor_reference(actor) do
    %{
      id: actor.id,
      type: "actor",
      attributes: %{
        name: actor.name
      }
    }
  end
end
