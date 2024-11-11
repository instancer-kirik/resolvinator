defmodule ResolvinatorWeb.API.SupplierContactController do
  use ResolvinatorWeb, :controller
  alias Resolvinator.Suppliers

  def index(conn, %{"supplier_id" => supplier_id}) do
    contacts = Suppliers.list_contacts(supplier_id)
    render(conn, :index, contacts: contacts)
  end

  def show(conn, %{"supplier_id" => supplier_id, "id" => id}) do
    contact = Suppliers.get_contact!(supplier_id, id)
    render(conn, :show, contact: contact)
  end
end 