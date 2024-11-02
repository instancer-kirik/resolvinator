defmodule ResolvinatorWeb.SupplierContactController do
  use ResolvinatorWeb, :controller

  alias Resolvinator.Suppliers
  alias Resolvinator.Suppliers.Contact

  action_fallback ResolvinatorWeb.FallbackController

  def index(conn, %{"supplier_id" => supplier_id}) do
    contacts = Suppliers.list_supplier_contacts(supplier_id)
    render(conn, :index, contacts: contacts)
  end

  def create(conn, %{"supplier_id" => supplier_id, "contact" => contact_params}) do
    with {:ok, contact} <- Suppliers.create_contact(Map.put(contact_params, "supplier_id", supplier_id)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/suppliers/#{supplier_id}/contacts/#{contact}")
      |> render(:show, contact: contact)
    end
  end

  def show(conn, %{"id" => id}) do
    contact = Suppliers.get_contact!(id)
    render(conn, :show, contact: contact)
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Suppliers.get_contact!(id)

    with {:ok, contact} <- Suppliers.update_contact(contact, contact_params) do
      render(conn, :show, contact: contact)
    end
  end

  def delete(conn, %{"id" => id}) do
    contact = Suppliers.get_contact!(id)

    with {:ok, _contact} <- Suppliers.delete_contact(contact) do
      send_resp(conn, :no_content, "")
    end
  end
end 