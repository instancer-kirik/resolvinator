defmodule ResolvinatorWeb.API.ProjectJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.{RiskJSON, ActorJSON, UserJSON}

  def index(%{projects: projects}) do
    %{data: for(project <- projects, do: data(project))}
  end

  def show(%{project: project}) do
    %{data: data(project)}
  end

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
        budget: project.budget,
        inserted_at: project.inserted_at,
        updated_at: project.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("risks", project.risks, &RiskJSON.data/1, includes)
    |> maybe_add_relationship("actors", project.actors, &ActorJSON.data/1, includes)
    |> maybe_add_relationship("creator", project.creator, &UserJSON.reference_data/1, includes)
    |> maybe_add_relationship("rewards", project.rewards, &RewardJSON.data/1, includes)

    Map.put(base, :relationships, relationships)
  end

  @doc """
  Minimal project data for relationships
  """
  def reference_data(project) do
    %{
      id: project.id,
      type: "project",
      attributes: %{
        name: project.name,
        status: project.status
      }
    }
  end
end
