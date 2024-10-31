defmodule ResolvinatorWeb.InventoryController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.JSONHelpers

  alias Resolvinator.Resources
  alias Resolvinator.Resources.InventoryItem

  def index(conn, params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]
    filters = Map.get(params, "filter", %{})

    {items, page_info} = Resources.list_inventory_items(
      params["project_id"],
      page: page,
      includes: includes,
      filters: filters
    )
    
    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(items, &InventoryJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def check_availability(conn, %{"id" => id, "quantity" => quantity}) do
    case Resources.check_item_availability(id, quantity) do
      {:ok, availability} ->
        json(conn, %{data: availability})
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Item not found"})
    end
  end

  def restock_suggestions(conn, %{"id" => id}) do
    with {:ok, item} <- Resources.get_inventory_item(id),
         {:ok, suggestions} <- Resources.generate_restock_suggestions(item) do
      json(conn, %{data: suggestions})
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def analyze_item(conn, %{"id" => id}) do
    with {:ok, item} <- Resources.get_inventory_item(id),
         {:ok, analysis} <- Resources.analyze_resource(item) do
      json(conn, %{
        data: %{
          resource_health: analysis.health_metrics,
          trends: analysis.trends,
          recommendations: analysis.recommendations,
          risks: analysis.risk_factors,
          opportunities: analysis.optimization_opportunities
        }
      })
    end
  end

  def get_trends(conn, %{"id" => id}) do
    with {:ok, item} <- Resources.get_inventory_item(id),
         {:ok, trends} <- Resources.get_resource_trends(item) do
      json(conn, %{data: trends})
    end
  end

  def adjust_stock(conn, %{"id" => id, "adjustment" => adjustment_params}) do
    with {:ok, item} <- Resources.get_inventory_item(id),
         {:ok, updated_item} <- Resources.adjust_stock(item, adjustment_params) do
      json(conn, %{data: InventoryJSON.data(updated_item)})
    end
  end

  # ... other standard CRUD actions ...
end 