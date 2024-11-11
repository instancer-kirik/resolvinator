defmodule ResolvinatorWeb.API.SupplierCatalogJSON do
  alias Resolvinator.Suppliers.Catalog

  def index(%{catalogs: catalogs}) do
    %{data: for(catalog <- catalogs, do: data(catalog))}
  end

  def show(%{catalog: catalog}) do
    %{data: data(catalog)}
  end

  def data(%Catalog{} = catalog, _opts \\ []) do
    %{
      id: catalog.id,
      type: "catalog",
      attributes: %{
        name: catalog.name,
        description: catalog.description,
        effective_date: catalog.effective_date,
        expiry_date: catalog.expiry_date,
        items: catalog.items,
        inserted_at: catalog.inserted_at,
        updated_at: catalog.updated_at
      }
    }
  end
end 