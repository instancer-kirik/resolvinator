defmodule ResolvinatorWeb.SupplierContactJSON do
  alias Resolvinator.Suppliers.Contact

  @doc """
  Renders a list of contacts.
  """
  def index(%{contacts: contacts}) do
    %{data: for(contact <- contacts, do: data(contact))}
  end

  @doc """
  Renders a single contact.
  """
  def show(%{contact: contact}) do
    %{data: data(contact)}
  end

  defp data(%Contact{} = contact) do
    %{
      id: contact.id,
      name: contact.name,
      email: contact.email,
      phone: contact.phone,
      role: contact.role,
      notes: contact.notes,
      inserted_at: contact.inserted_at
    }
  end
end 