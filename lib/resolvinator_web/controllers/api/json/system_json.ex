defmodule ResolvinatorWeb.API.SystemJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.{ProjectJSON, UserJSON}

  def data(system, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])

    base = %{
      id: system.id,
      type: "system",
      attributes: %{
        name: system.name,
        description: system.description,
        system_type: system.system_type,
        lifecycle_stage: system.lifecycle_stage,
        version: system.version,
        technical_stack: system.technical_stack,
        dependencies: system.dependencies,
        configuration: system.configuration,
        health_metrics: system.health_metrics,
        documentation_url: system.documentation_url,
        status: system.status,
        metadata: system.metadata,
        inserted_at: system.inserted_at,
        updated_at: system.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("project", system.project, &ProjectJSON.reference_data/1, includes)
    |> maybe_add_relationship("owner", system.owner, &UserJSON.reference_data/1, includes)
    |> maybe_add_relationship("maintainers", system.maintainers, &UserJSON.reference_data/1, includes)
    |> maybe_add_relationship("related_systems", system.related_systems, &reference_data/1, includes)

    Map.put(base, :relationships, relationships)
  end

  def reference_data(system) do
    %{
      id: system.id,
      type: "system",
      attributes: %{
        name: system.name,
        system_type: system.system_type,
        status: system.status
      }
    }
  end
end
