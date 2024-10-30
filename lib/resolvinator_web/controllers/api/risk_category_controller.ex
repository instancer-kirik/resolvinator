defmodule ResolvinatorWeb.RiskCategoryController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Risks
  alias Resolvinator.Risks.Category

  def index(conn, %{"project_id" => project_id} = params) do
    categories = Risks.list_risk_categories(project_id, params)
    json(conn, %{data: Enum.map(categories, &category_json/1)})
  end

  def create(conn, %{"project_id" => project_id, "category" => category_params}) do
    create_params = Map.merge(category_params, %{
      "project_id" => project_id,
      "creator_id" => conn.assigns.current_user.id
    })

    case Risks.create_category(create_params) do
      {:ok, category} ->
        conn
        |> put_status(:created)
        |> json(%{data: category_json(category)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    category = Risks.get_risk_category!(project_id, id)
    json(conn, %{data: category_json(category)})
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Risks.get_risk_category!(id)

    case Risks.update_category(category, category_params) do
      {:ok, category} ->
        json(conn, %{data: category_json(category)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Risks.get_risk_category!(id)
    
    case Risks.delete_category(category) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} -> 
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete category"})
    end
  end

  defp category_json(category) do
    %{
      id: category.id,
      name: category.name,
      description: category.description,
      color: category.color,
      assessment_criteria: category.assessment_criteria,
      project_id: category.project_id,
      inserted_at: category.inserted_at,
      updated_at: category.updated_at
    }
  end

  defp format_errors(changeset), do: Resolvinator.ChangesetErrors.format_errors(changeset)
end 