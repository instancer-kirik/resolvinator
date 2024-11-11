defmodule ResolvinatorWeb.API.SupplierContactJSON do
  alias Resolvinator.Suppliers.Contact

  def index(%{contacts: contacts}) do
    %{data: for(contact <- contacts, do: data(contact))}
  end

  def show(%{contact: contact}) do
    %{data: data(contact)}
  end

  def data(%Contact{} = contact, _opts \\ []) do
    %{
      id: contact.id,
      type: "contact",
      attributes: %{
        name: contact.name,
        email: contact.email,
        phone: contact.phone,
        role: contact.role,
        notes: contact.notes,
        inserted_at: contact.inserted_at,
        updated_at: contact.updated_at
      }
    }
  end
end 