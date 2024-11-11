defmodule ResolvinatorWeb.API.SupplierCatalogController do
  use ResolvinatorWeb, :controller
  alias Resolvinator.Suppliers

  def index(conn, %{"supplier_id" => supplier_id}) do
    catalog_items = Suppliers.list_catalog_items(supplier_id)
    render(conn, :index, catalog_items: catalog_items)
  end

  def show(conn, %{"supplier_id" => supplier_id, "id" => id}) do
    catalog_item = Suppliers.get_catalog_item!(supplier_id, id)
    render(conn, :show, catalog_item: catalog_item)
  end
end 