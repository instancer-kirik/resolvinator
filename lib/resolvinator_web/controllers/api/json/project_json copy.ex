defmodule ResolvinatorWeb.ProjectJSON do
  import ResolvinatorWeb.JSONHelpers
  alias ResolvinatorWeb.{RiskJSON, ActorJSON, UserJSON}

  def data(project, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: project.id,
      type: "project",
      attributes: %{
        name: project.name,
        description: project.description,
        status: project.status,
        risk_appetite: project.risk_appetite,
        start_date: project.start_date,
        target_date: project.target_date,
        completion_date: project.completion_date,
        inserted_at: project.inserted_at,
        updated_at: project.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("risks", project.risks, &RiskJSON.data/1, includes)
    |> maybe_add_relationship("actors", project.actors, &ActorJSON.data/1, includes)
    |> maybe_add_relationship("creator", project.creator, &UserJSON.data/1, includes)

    Map.put(base, :relationships, relationships)
  end 
end 