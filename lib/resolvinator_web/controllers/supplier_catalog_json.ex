defmodule ResolvinatorWeb.SupplierCatalogJSON do
  alias Resolvinator.Suppliers.Catalog

  @doc """
  Renders a list of catalogs.
  """
  def index(%{catalogs: catalogs}) do
    %{data: for(catalog <- catalogs, do: data(catalog))}
  end

  @doc """
  Renders a single catalog.
  """
  def show(%{catalog: catalog}) do
    %{data: data(catalog)}
  end

  defp data(%Catalog{} = catalog) do
    %{
      id: catalog.id,
      name: catalog.name,
      description: catalog.description,
      effective_date: catalog.effective_date,
      expiry_date: catalog.expiry_date,
      items: catalog.items,
      inserted_at: catalog.inserted_at
    }
  end
end 