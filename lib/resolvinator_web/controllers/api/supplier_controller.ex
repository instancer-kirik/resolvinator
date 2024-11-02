defmodule ResolvinatorWeb.SupplierController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Suppliers
  alias Resolvinator.Suppliers.Supplier

  action_fallback ResolvinatorWeb.FallbackController

  def index(conn, _params) do
    suppliers = Suppliers.list_suppliers()
    render(conn, :index, suppliers: suppliers)
  end

  def create(conn, %{"supplier" => supplier_params}) do
    with {:ok, %Supplier{} = supplier} <- Suppliers.create_supplier(supplier_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/suppliers/#{supplier}")
      |> render(:show, supplier: supplier)
    end
  end

  def show(conn, %{"id" => id}) do
    supplier = Suppliers.get_supplier!(id)
    render(conn, :show, supplier: supplier)
  end

  def update(conn, %{"id" => id, "supplier" => supplier_params}) do
    supplier = Suppliers.get_supplier!(id)

    with {:ok, %Supplier{} = supplier} <- Suppliers.update_supplier(supplier, supplier_params) do
      render(conn, :show, supplier: supplier)
    end
  end

  def delete(conn, %{"id" => id}) do
    supplier = Suppliers.get_supplier!(id)

    with {:ok, %Supplier{}} <- Suppliers.delete_supplier(supplier) do
      send_resp(conn, :no_content, "")
    end
  end

  def get_performance(conn, %{"supplier_id" => id}) do
    supplier = Suppliers.get_supplier!(id)
    performance = Suppliers.get_supplier_performance(supplier)
    render(conn, :performance, performance: performance)
  end

  def get_pricing(conn, %{"supplier_id" => id}) do
    supplier = Suppliers.get_supplier!(id)
    pricing = Suppliers.get_supplier_pricing(supplier)
    render(conn, :pricing, pricing: pricing)
  end
end 