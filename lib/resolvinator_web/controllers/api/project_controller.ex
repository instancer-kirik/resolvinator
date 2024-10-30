defmodule ResolvinatorWeb.ProjectController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.JSONHelpers

  alias Resolvinator.Projects
  alias Resolvinator.Projects.Project

  def index(conn, params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]

    {projects, page_info} = Projects.list_projects(page: page, includes: includes)
    
    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(projects, &ProjectJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.create_project(project_params) do
      {:ok, project} ->
        conn
        |> put_status(:created)
        |> json(%{data: project_json(project)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    json(conn, %{data: project_json(project)})
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    case Projects.update_project(project, project_params) do
      {:ok, project} ->
        json(conn, %{data: project_json(project)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    
    case Projects.delete_project(project) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")
      
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete project"})
    end
  end

  # JSON formatting helpers
  defp project_json(project) do
    %{
      id: project.id,
      name: project.name,
      description: project.description,
      status: project.status,
      risk_appetite: project.risk_appetite,
      start_date: project.start_date,
      target_date: project.target_date,
      completion_date: project.completion_date,
      settings: project.settings,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end 