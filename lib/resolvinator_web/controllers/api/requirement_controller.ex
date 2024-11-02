defmodule ResolvinatorWeb.API.RequirementController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.JSONHelpers

  alias Resolvinator.Resources
  #alias Resolvinator.Resources.Requirement

  def index(conn, params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]

    {requirements, page_info} = Resources.list_requirements(
      params["project_id"],
      params["risk_id"], 
      params["mitigation_id"], 
      page: page, 
      includes: includes
    )
    
    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(requirements, &RequirementJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"requirement" => params}) do
    create_params = Map.put(params, "creator_id", conn.assigns.current_user.id)

    case Resources.create_requirement(create_params) do
      {:ok, requirement} ->
        conn
        |> put_status(:created)
        |> json(%{data: RequirementJSON.data(requirement)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Resources.get_requirement(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Requirement not found"})

      requirement ->
        conn
        |> put_status(:ok)
        |> json(%{data: RequirementJSON.data(requirement)})
    end
  end

  def update(conn, %{"id" => id, "requirement" => requirement_params}) do
    case Resources.update_requirement(id, requirement_params) do
      {:ok, requirement} ->
        conn
        |> put_status(:ok)
        |> json(%{data: RequirementJSON.data(requirement)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    case Resources.delete_requirement(id) do
      {:ok, _} ->
        conn
        |> put_status(:no_content)
        |> json(%{})

      {:error, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Requirement not found"})
    end
  end
end 