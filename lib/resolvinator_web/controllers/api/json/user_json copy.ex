defmodule ResolvinatorWeb.UserJSON do
  import ResolvinatorWeb.JSONHelpers
  alias ResolvinatorWeb.ActorJSON

  def data(user, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: user.id,
      type: "user",
      attributes: %{
        email: user.email,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("actors", user.actors, &ActorJSON.data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end 