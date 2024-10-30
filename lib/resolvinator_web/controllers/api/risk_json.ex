defmodule ResolvinatorWeb.RiskJSON do
  alias Resolvinator.Risks.Risk

  @doc """
  Renders a risk with optional includes.
  Options:
    * :includes - list of relationships to include (e.g., ["category", "impacts", "mitigations"])
    * :preload - whether to force preload of relationships (default: false)
  """
  def data(%Risk{} = risk, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: risk.id,
      name: risk.name,
      description: risk.description,
      probability: risk.probability,
      impact: risk.impact,
      priority: risk.priority,
      status: risk.status,
      mitigation_status: risk.mitigation_status,
      detection_date: risk.detection_date,
      review_date: risk.review_date,
      project_id: risk.project_id,
      risk_category_id: risk.risk_category_id,
      inserted_at: risk.inserted_at,
      updated_at: risk.updated_at,
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("category", risk.risk_category, &category_data/1, includes)
    |> maybe_add_relationship("impacts", risk.impacts, &impact_data/1, includes)
    |> maybe_add_relationship("mitigations", risk.mitigations, &mitigation_data/1, includes)
    |> maybe_add_relationship("creator", risk.creator, &user_data/1, includes)
    |> maybe_add_relationship("project", risk.project, &project_data/1, includes)

    Map.put(base, :relationships, relationships)
  end

  defp maybe_add_relationship(relationships, key, nil, _formatter, _includes), do: relationships
  defp maybe_add_relationship(relationships, key, data, _formatter, includes) when not is_list(data) and key not in includes, do:
    relationships
  defp impact_data(impact) do
    %{
      id: impact.id,
      description: impact.description,
      area: impact.area,
      severity: impact.severity,
      likelihood: impact.likelihood,
      estimated_cost: impact.estimated_cost,
      timeframe: impact.timeframe
    }
  end

  defp mitigation_data(mitigation) do
    %{
      id: mitigation.id,
      description: mitigation.description,
      strategy: mitigation.strategy,
      status: mitigation.status,
      effectiveness: mitigation.effectiveness,
      cost: mitigation.cost,
      start_date: mitigation.start_date,
      target_date: mitigation.target_date,
      completion_date: mitigation.completion_date
    }
  end

  defp category_data(category) do
    %{
      id: category.id,
      name: category.name,
      description: category.description
    }
  end

  defp user_data(user) do
    %{
      id: user.id,
      name: user.name
    }
  end

  defp project_data(project) do
    %{
      id: project.id,
      name: project.name
    }
  end
end 