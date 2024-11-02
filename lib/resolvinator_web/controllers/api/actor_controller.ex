defmodule ResolvinatorWeb.API.ActorController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Actors
  action_fallback ResolvinatorWeb.FallbackController

  def index(conn, %{"project_id" => project_id} = params) do
    {actors, page_info} = Actors.list_project_actors(project_id, 
      page: params["page"],
      includes: params["include"],
      filters: params["filter"],
      sort: params["sort"]
    )

    render(conn, :index, actors: actors, page_info: page_info)
  end

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    actor = Actors.get_project_actor!(project_id, id)
    render(conn, :show, actor: actor)
  end

  def create(conn, %{"project_id" => project_id, "actor" => actor_params}) do
    actor_params = Map.put(actor_params, "project_id", project_id)
    actor_params = Map.put(actor_params, "creator_id", conn.assigns.current_user.id)

    with {:ok, actor} <- Actors.create_actor(actor_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/projects/#{project_id}/actors/#{actor.id}")
      |> render(:show, actor: actor)
    end
  end

  def update(conn, %{"project_id" => project_id, "id" => id, "actor" => actor_params}) do
    actor = Actors.get_project_actor!(project_id, id)

    with {:ok, actor} <- Actors.update_actor(actor, actor_params) do
      render(conn, :show, actor: actor)
    end
  end

  def delete(conn, %{"project_id" => project_id, "id" => id}) do
    actor = Actors.get_project_actor!(project_id, id)

    with {:ok, _actor} <- Actors.delete_actor(actor) do
      send_resp(conn, :no_content, "")
    end
  end
end 