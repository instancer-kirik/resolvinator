defmodule ResolvinatorWeb.API.ImpactController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.API.JSONHelpers

  alias Resolvinator.Risks
  alias ResolvinatorWeb.API.{ImpactJSON, ErrorJSON}

  def index(conn, %{"risk_id" => risk_id} = params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]

    {impacts, page_info} = Risks.list_impacts(risk_id, page: page, includes: includes)

    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(impacts, &ImpactJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"project_id" => _project_id, "risk_id" => risk_id, "impact" => impact_params}) do
    create_params = Map.merge(impact_params, %{
      "risk_id" => risk_id,
      "creator_id" => conn.assigns.current_user.id
    })

    case Risks.create_impact(create_params) do
      {:ok, impact} ->
        conn
        |> put_status(:created)
        |> json(%{data: ImpactJSON.data(impact)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(ErrorJSON.error(changeset))
    end
  end

  def show(conn, %{"project_id" => _project_id, "risk_id" => _risk_id, "id" => id} = params) do
    includes = params["include"]
    impact = Risks.get_impact!(id)
    json(conn, %{data: ImpactJSON.data(impact, includes: includes)})
  end

  def update(conn, %{"id" => id, "impact" => impact_params}) do
    impact = Risks.get_impact!(id)

    case Risks.update_impact(impact, impact_params) do
      {:ok, impact} ->
        json(conn, %{data: ImpactJSON.data(impact)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(ErrorJSON.error(changeset))
    end
  end

  def delete(conn, %{"id" => id}) do
    impact = Risks.get_impact!(id)

    case Risks.delete_impact(impact) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(ErrorJSON.error(:delete_failed, "Could not delete impact"))
    end
  end
end
