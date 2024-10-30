defmodule ResolvinatorWeb.ActorController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.JSONHelpers

  alias Resolvinator.Actors
  alias Resolvinator.Actors.Actor

  def index(conn, %{"project_id" => project_id} = params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]

    {actors, page_info} = Actors.list_project_actors(project_id, page: page, includes: includes)
    
    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(actors, &ActorJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"project_id" => project_id, "actor" => actor_params}) do
    create_params = Map.merge(actor_params, %{
      "project_id" => project_id,
      "creator_id" => conn.assigns.current_user.id
    })

    case Actors.create_actor(create_params) do
      {:ok, actor} ->
        conn
        |> put_status(:created)
        |> json(%{data: actor_json(actor)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    actor = Actors.get_project_actor!(project_id, id)
    json(conn, %{data: actor_json(actor)})
  end

  def update(conn, %{"project_id" => project_id, "id" => id, "actor" => actor_params}) do
    actor = Actors.get_project_actor!(project_id, id)

    case Actors.update_actor(actor, actor_params) do
      {:ok, actor} ->
        json(conn, %{data: actor_json(actor)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"project_id" => project_id, "id" => id}) do
    actor = Actors.get_project_actor!(project_id, id)
    
    case Actors.delete_actor(actor) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} -> 
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete actor"})
    end
  end

  defp actor_json(actor) do
    %{
      id: actor.id,
      name: actor.name,
      type: actor.type,
      description: actor.description,
      role: actor.role,
      influence_level: actor.influence_level,
      contact_info: actor.contact_info,
      status: actor.status,
      project_id: actor.project_id
    }
  end
end 