defmodule ResolvinatorWeb.API.SupplierJSON do
  alias Resolvinator.Suppliers.Supplier

  def index(%{suppliers: suppliers}) do
    %{data: for(supplier <- suppliers, do: data(supplier))}
  end

  def show(%{supplier: supplier}) do
    %{data: data(supplier)}
  end

  def performance(%{performance: performance}) do
    %{data: performance}
  end

  def pricing(%{pricing: pricing}) do
    %{data: pricing}
  end

  def data(%Supplier{} = supplier, _opts \\ []) do
    %{
      id: supplier.id,
      type: "supplier",
      attributes: %{
        name: supplier.name,
        code: supplier.code,
        type: supplier.type,
        status: supplier.status,
        rating: supplier.rating,
        payment_terms: supplier.payment_terms,
        lead_time_days: supplier.lead_time_days,
        minimum_order: supplier.minimum_order,
        website: supplier.website,
        integration_type: supplier.integration_type,
        inserted_at: supplier.inserted_at,
        updated_at: supplier.updated_at
      }
    }
  end
end 