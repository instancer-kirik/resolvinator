defmodule ResolvinatorWeb.API.MitigationController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.API.JSONHelpers

  alias Resolvinator.Risks
  #alias Resolvinator.Risks.Mitigation

  def index(conn, %{"risk_id" => risk_id} = params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]

    {mitigations, page_info} = Risks.list_risk_mitigations(risk_id, page: page, includes: includes)

    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(mitigations, &MitigationJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"project_id" => _project_id, "risk_id" => risk_id, "mitigation" => mitigation_params}) do
    create_params = Map.merge(mitigation_params, %{
      "risk_id" => risk_id,
      "creator_id" => conn.assigns.current_user.id
    })

    case Risks.create_mitigation(create_params) do
      {:ok, mitigation} ->
        conn
        |> put_status(:created)
        |> json(%{data: mitigation_json(mitigation)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"project_id" => project_id, "risk_id" => risk_id, "id" => id}) do
    mitigation = Risks.get_risk_mitigation!(project_id, risk_id, id)
    json(conn, %{data: mitigation_json(mitigation)})
  end

  def update(conn, %{"id" => id, "mitigation" => mitigation_params}) do
    mitigation = Risks.get_mitigation!(id)

    case Risks.update_mitigation(mitigation, mitigation_params) do
      {:ok, mitigation} ->
        json(conn, %{data: mitigation_json(mitigation)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    mitigation = Risks.get_mitigation!(id)

    case Risks.delete_mitigation(mitigation) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete mitigation"})
    end
  end

  defp mitigation_json(mitigation) do
    %{
      id: mitigation.id,
      description: mitigation.description,
      strategy: mitigation.strategy,
      status: mitigation.status,
      effectiveness: mitigation.effectiveness,
      cost: mitigation.cost,
      start_date: mitigation.start_date,
      target_date: mitigation.target_date,
      completion_date: mitigation.completion_date,
      notes: mitigation.notes,
      risk_id: mitigation.risk_id,
      tasks: Enum.map(mitigation.tasks || [], &task_json/1),
      inserted_at: mitigation.inserted_at,
      updated_at: mitigation.updated_at
    }
  end

  defp task_json(task) do
    %{
      id: task.id,
      name: task.name,
      description: task.description,
      status: task.status,
      due_date: task.due_date,
      completion_date: task.completion_date,
      assignee_id: task.assignee_id
    }
  end

  defp format_errors(changeset), do: Resolvinator.ChangesetErrors.format_errors(changeset)
end
