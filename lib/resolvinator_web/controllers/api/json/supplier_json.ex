defmodule ResolvinatorWeb.API.SupplierJSON do
  alias Resolvinator.Suppliers.Supplier

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