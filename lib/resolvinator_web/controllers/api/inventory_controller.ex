defmodule ResolvinatorWeb.API.InventoryController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.JSONHelpers

  alias Resolvinator.Resources
 # alias Resolvinator.Resources.InventoryItem

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

  def get_pricing(conn, %{"id" => id}) do
    with {:ok, pricing} <- Resources.get_item_pricing(id) do
      json(conn, %{data: pricing})
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Pricing information not found"})
    end
  end

  def create_order(conn, %{"id" => id, "order_details" => order_details}) do
    with {:ok, order} <- Resources.create_order(id, order_details) do
      json(conn, %{data: order})
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def list_sources(conn, _params) do
    sources = Resources.list_inventory_sources()
    json(conn, %{data: sources})
  end

  def compare_sources(conn, %{"source_ids" => source_ids}) do
    with {:ok, comparison} <- Resources.compare_inventory_sources(source_ids) do
      json(conn, %{data: comparison})
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  def create(conn, %{"inventory_item" => item_params}) do
    create_params = Map.put(item_params, "creator_id", conn.assigns.current_user.id)

    case Resources.create_inventory_item(create_params) do
      {:ok, item} ->
        conn
        |> put_status(:created)
        |> json(%{data: InventoryJSON.data(item)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Resources.get_inventory_item(id) do
      {:ok, item} ->
        conn
        |> put_status(:ok)
        |> json(%{data: InventoryJSON.data(item)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Inventory item not found"})
    end
  end

  def update(conn, %{"id" => id, "inventory_item" => item_params}) do
    with {:ok, item} <- Resources.get_inventory_item(id),
         {:ok, updated_item} <- Resources.update_inventory_item(item, item_params) do
      json(conn, %{data: InventoryJSON.data(updated_item)})
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Inventory item not found"})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, item} <- Resources.get_inventory_item(id),
         {:ok, _} <- Resources.delete_inventory_item(item) do
      send_resp(conn, :no_content, "")
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Inventory item not found"})
      
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete inventory item"})
    end
  end
end 