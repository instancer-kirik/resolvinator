defmodule ResolvinatorWeb.API.RiskJSON do
  alias Resolvinator.Risks.Risk
  import ResolvinatorWeb.API.JSONHelpers

  @doc """
  Renders a list of risks.
  """
  def index(%{risks: risks, page_info: page_info}) do
    %{
      data: for(risk <- risks, do: data(risk)),
      page_info: page_info
    }
  end

  @doc """
  Renders a single risk.
  """
  def show(%{risk: risk}) do
    %{data: data(risk)}
  end

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
      type: "risk",
      attributes: %{
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
        updated_at: risk.updated_at
      },
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

  # Private helper functions for relationship data formatting
  defp category_data(category) do
    %{
      id: category.id,
      type: "risk_category",
      attributes: %{
        name: category.name,
        description: category.description
      }
    }
  end

  defp impact_data(impact) do
    %{
      id: impact.id,
      type: "impact",
      attributes: %{
        description: impact.description,
        area: impact.area,
        severity: impact.severity,
        likelihood: impact.likelihood,
        estimated_cost: impact.estimated_cost,
        timeframe: impact.timeframe
      }
    }
  end

  defp mitigation_data(mitigation) do
    %{
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
        completion_date: mitigation.completion_date
      }
    }
  end

  defp project_data(project) do
    %{
      id: project.id,
      type: "project",
      attributes: %{
        name: project.name
      }
    }
  end
end 