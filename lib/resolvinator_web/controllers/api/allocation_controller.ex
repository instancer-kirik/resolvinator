defmodule ResolvinatorWeb.API.AllocationController do
  use ResolvinatorWeb, :controller
  alias Resolvinator.ChangesetErrors
  import ResolvinatorWeb.JSONHelpers, only: [paginate: 2]
  #alias ResolvinatorWeb.JSONHelpers
  alias Resolvinator.Resources
  # alias Resolvinator.Resources.Allocation

  def index(conn, params) do
    page = params["page"] || %{"number" => 1, "size" => 20}
    includes = params["include"]

    {allocations, page_info} = Resources.list_allocations(
      params["risk_id"], 
      params["mitigation_id"], 
      page: page, 
      includes: includes
    )
    
    conn
    |> put_status(:ok)
    |> json(paginate(
      Enum.map(allocations, &AllocationJSON.data(&1, includes: includes)),
      page_info
    ))
  end

  def create(conn, %{"allocation" => allocation_params}) do
    create_params = Map.put(allocation_params, "creator_id", conn.assigns.current_user.id)

    case Resources.create_allocation(create_params) do
      {:ok, allocation} ->
        conn
        |> put_status(:created)
        |> json(%{data: AllocationJSON.data(allocation)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    allocation = Resources.get_allocation!(id)
    json(conn, %{data: AllocationJSON.data(allocation)})
  end

  def update(conn, %{"id" => id, "allocation" => allocation_params}) do
    allocation = Resources.get_allocation!(id)

    case Resources.update_allocation(allocation, allocation_params) do
      {:ok, allocation} ->
        json(conn, %{data: AllocationJSON.data(allocation)})
      
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: ChangesetErrors.format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    allocation = Resources.get_allocation!(id)
    
    case Resources.delete_allocation(allocation) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")
      
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Could not delete allocation"})
    end
  end
end 