defmodule ResolvinatorWeb.API.AllocationController do
  use ResolvinatorWeb, :controller
  import ResolvinatorWeb.API.JSONHelpers#, only: [paginate: 2]
  alias Resolvinator.Resources
  alias ResolvinatorWeb.API.{AllocationJSON, ErrorJSON}

  def index(conn, %{"inventory_item_id" => item_id} = params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]

    {allocations, page_info} = Resources.list_allocations(item_id, page: page, includes: includes)

    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(allocations, &AllocationJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"inventory_item_id" => item_id, "allocation" => allocation_params}) do
    create_params = Map.merge(allocation_params, %{
      "inventory_item_id" => item_id,
      "creator_id" => conn.assigns.current_user.id
    })

    case Resources.create_allocation(create_params) do
      {:ok, allocation} ->
        conn
        |> put_status(:created)
        |> json(%{data: AllocationJSON.data(allocation)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(ErrorJSON.error(changeset))
    end
  end

  def show(conn, %{"id" => id} = params) do
    includes = params["include"]
    allocation = Resources.get_allocation!(id)
    json(conn, %{data: AllocationJSON.data(allocation, includes: includes)})
  end

  def update(conn, %{"id" => id, "allocation" => allocation_params}) do
    allocation = Resources.get_allocation!(id)

    case Resources.update_allocation(allocation, allocation_params) do
      {:ok, allocation} ->
        json(conn, %{data: AllocationJSON.data(allocation)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(ErrorJSON.error(changeset))
    end
  end

  def delete(conn, %{"id" => id}) do
    allocation = Resources.get_allocation!(id)

    case Resources.delete_allocation(allocation) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(ErrorJSON.error(:delete_failed, "Could not delete allocation"))
    end
  end
end
