defmodule ResolvinatorWeb.API.MitigationTaskJSON do
  import ResolvinatorWeb.API.JSONHelpers

  def data(task, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])

    base = %{
      id: task.id,
      type: "mitigation_task",
      attributes: %{
        name: task.name,
        description: task.description,
        status: task.status,
        due_date: task.due_date,
        completion_date: task.completion_date,
        notes: task.notes,
        inserted_at: task.inserted_at,
        updated_at: task.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("mitigation", task.mitigation, &ResolvinatorWeb.API.MitigationJSON.data/1, includes)
    |> maybe_add_relationship("assignee", task.assignee, &ResolvinatorWeb.UserJSON.data/1, includes)
    |> maybe_add_relationship("creator", task.creator, &ResolvinatorWeb.UserJSON.data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end
