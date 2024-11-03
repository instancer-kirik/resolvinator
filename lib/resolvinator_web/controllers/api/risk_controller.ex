defmodule ResolvinatorWeb.API.RiskController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.API.JSONHelpers

  alias Resolvinator.Risks
  alias Resolvinator.Risks.Risk

  def index(conn, %{"project_id" => project_id} = params) do
    page = params["page"] || %{"number" => "1", "size" => "20"}
    includes = params["include"]
    filters = Map.get(params, "filter", %{})
    sort = params["sort"]

    {risks, page_info} = Risks.list_project_risks(
      project_id,
      page: page,
      includes: includes,
      filters: filters,
      sort: sort
    )

    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(risks, &RiskJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"project_id" => _project_id, "risk" => risk_params}) do
    case Risks.create_risk(risk_params) do
      {:ok, risk} ->
        conn
        |> put_status(:created)
        |> json(%{data: RiskJSON.data(risk)})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(format_error(changeset))

      {:error, type, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(format_error(type, message))
    end
  end

  def show(conn, %{"project_id" => project_id, "id" => id} = params) do
    includes = case params["include"] do
      nil -> []
      includes when is_binary(includes) -> String.split(includes, ",")
      includes when is_list(includes) -> includes
    end

    risk = Risks.get_project_risk!(project_id, id, includes)
    json(conn, %{data: ResolvinatorWeb.RiskJSON.data(risk, includes: includes)})
  end

  def update(conn, %{"project_id" => project_id, "id" => id, "risk" => risk_params}) do
    risk = Risks.get_project_risk!(project_id, id)

    with {:ok, %Risk{} = risk} <- Risks.update_risk(risk, risk_params) do
      json(conn, %{data: ResolvinatorWeb.RiskJSON.data(risk)})
    end
  end

  def delete(conn, %{"project_id" => project_id, "id" => id}) do
    risk = Risks.get_project_risk!(project_id, id)

    with {:ok, %Risk{}} <- Risks.delete_risk(risk) do
      send_resp(conn, :no_content, "")
    end
  end
end
