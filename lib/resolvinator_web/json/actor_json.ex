defmodule ResolvinatorWeb.ActorJSON do
  import ResolvinatorWeb.JSONHelpers

  def data(actor, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: actor.id,
      type: "actor",
      attributes: %{
        name: actor.name,
        type: actor.type,
        description: actor.description,
        role: actor.role,
        influence_level: actor.influence_level,
        contact_info: actor.contact_info,
        status: actor.status,
        inserted_at: actor.inserted_at,
        updated_at: actor.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("project", actor.project, &ResolvinatorWeb.ProjectJSON.data/1, includes)
    |> maybe_add_relationship("parent_actor", actor.parent_actor, &ResolvinatorWeb.ActorJSON.data/1, includes)
    |> maybe_add_relationship("creator", actor.creator, &user_data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end 