defmodule ResolvinatorWeb.API.UserJSON do
  import ResolvinatorWeb.API.JSONHelpers
  alias ResolvinatorWeb.API.ActorJSON
  alias ResolvinatorWeb.API.ProblemJSON
  alias ResolvinatorWeb.API.SolutionJSON
  alias ResolvinatorWeb.API.AdvantageJSON
  alias ResolvinatorWeb.API.LessonJSON

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  @doc """
  Renders a user with optional includes.
  Options:
    * :includes - list of relationships to include (e.g., ["actors"])
  """
  def data(user, opts \\ []) do
    includes = Keyword.get(opts, :includes, [])
    
    base = %{
      id: user.id,
      type: "user",
      attributes: %{
        email: user.email,
        username: user.username,
        is_admin: user.is_admin,
        status: user.status,
        preferences: user.preferences,
        confirmed_at: user.confirmed_at,
        banned_at: user.banned_at,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      },
      relationships: %{}
    }

    relationships = %{}
    |> maybe_add_relationship("actors", user.actors, &ActorJSON.data/1, includes)
    |> maybe_add_relationship("created_problems", user.created_problems, &ProblemJSON.data/1, includes)
    |> maybe_add_relationship("created_solutions", user.created_solutions, &SolutionJSON.data/1, includes)
    |> maybe_add_relationship("created_advantages", user.created_advantages, &AdvantageJSON.data/1, includes)
    |> maybe_add_relationship("created_lessons", user.created_lessons, &LessonJSON.data/1, includes)

    Map.put(base, :relationships, relationships)
  end
end 