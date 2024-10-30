defmodule ResolvinatorWeb.MitigationTaskController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.JSONHelpers

  alias Resolvinator.Risks
  alias Resolvinator.Risks.MitigationTask

  def index(conn, %{"mitigation_id" => mitigation_id} = params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]

    {tasks, page_info} = Risks.list_mitigation_tasks(mitigation_id, page: page, includes: includes)
    
    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(tasks, &MitigationTaskJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"mitigation_id" => mitigation_id, "task" => task_params}) do
    create_params = Map.merge(task_params, %{
      "mitigation_id" => mitigation_id,
      "creator_id" => conn.assigns.current_user.id
    })

    case Risks.create_mitigation_task(create_params) do
      {:ok, task} ->
        conn
        |> put_status(:created)
        |> json(%{data: task_json(task)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    task = Risks.get_mitigation_task!(id)
    json(conn, %{data: task_json(task)})
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Risks.get_mitigation_task!(id)

    case Risks.update_mitigation_task(task, task_params) do
      {:ok, task} ->
        json(conn, %{data: task_json(task)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Risks.get_mitigation_task!(id)
    
    case Risks.delete_mitigation_task(task) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} -> 
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete task"})
    end
  end

  defp task_json(task) do
    %{
      id: task.id,
      name: task.name,
      description: task.description,
      status: task.status,
      due_date: task.due_date,
      completion_date: task.completion_date,
      mitigation_id: task.mitigation_id,
      assignee_id: task.assignee_id,
      inserted_at: task.inserted_at,
      updated_at: task.updated_at
    }
  end

  defp format_errors(changeset), do: Resolvinator.ChangesetErrors.format_errors(changeset)
end 