defmodule ResolvinatorWeb.SupplierCatalogController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Suppliers
  alias Resolvinator.Suppliers.Catalog

  action_fallback ResolvinatorWeb.FallbackController

  def index(conn, %{"supplier_id" => supplier_id}) do
    catalogs = Suppliers.list_supplier_catalogs(supplier_id)
    render(conn, :index, catalogs: catalogs)
  end

  def create(conn, %{"supplier_id" => supplier_id, "catalog" => catalog_params}) do
    with {:ok, catalog} <- Suppliers.create_catalog(Map.put(catalog_params, "supplier_id", supplier_id)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/suppliers/#{supplier_id}/catalogs/#{catalog}")
      |> render(:show, catalog: catalog)
    end
  end

  def show(conn, %{"id" => id}) do
    catalog = Suppliers.get_catalog!(id)
    render(conn, :show, catalog: catalog)
  end

  def update(conn, %{"id" => id, "catalog" => catalog_params}) do
    catalog = Suppliers.get_catalog!(id)

    with {:ok, catalog} <- Suppliers.update_catalog(catalog, catalog_params) do
      render(conn, :show, catalog: catalog)
    end
  end

  def delete(conn, %{"id" => id}) do
    catalog = Suppliers.get_catalog!(id)

    with {:ok, _catalog} <- Suppliers.delete_catalog(catalog) do
      send_resp(conn, :no_content, "")
    end
  end
end 