defmodule ResolvinatorWeb.API.ActorJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias Resolvinator.Actors.Actor
  alias ResolvinatorWeb.API.{UserJSON, ProjectJSON}

  @doc """
  Renders a list of actors.
  """
  def index(%{actors: actors, page_info: page_info}) do
    paginate(
      Enum.map(actors, &data/1),
      page_info
    )
  end

  @doc """
  Renders a single actor.
  """
  def show(%{actor: actor}) do
    %{data: data(actor)}
  end

  @doc """
  Renders the actor data structure.
  """
  def data(%Actor{} = actor, opts \\ []) do
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
    |> maybe_add_relationship("project", actor.project, &ProjectJSON.data/1, includes)
    |> maybe_add_relationship("parent_actor", actor.parent_actor, &data/1, includes)
    |> maybe_add_relationship("creator", actor.creator, &UserJSON.data/1, includes)

    %{base | relationships: relationships}
  end
end
