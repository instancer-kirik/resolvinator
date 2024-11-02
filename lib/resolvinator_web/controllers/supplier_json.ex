defmodule ResolvinatorWeb.SupplierJSON do
  alias Resolvinator.Suppliers.Supplier

  @doc """
  Renders a list of suppliers.
  """
  def index(%{suppliers: suppliers}) do
    %{data: for(supplier <- suppliers, do: data(supplier))}
  end

  @doc """
  Renders a single supplier.
  """
  def show(%{supplier: supplier}) do
    %{data: data(supplier)}
  end

  def performance(%{performance: performance}) do
    %{data: performance}
  end

  def pricing(%{pricing: pricing}) do
    %{data: pricing}
  end

  defp data(%Supplier{} = supplier) do
    %{
      id: supplier.id,
      name: supplier.name,
      code: supplier.code,
      type: supplier.type,
      status: supplier.status,
      rating: supplier.rating,
      payment_terms: supplier.payment_terms,
      lead_time_days: supplier.lead_time_days,
      minimum_order: supplier.minimum_order,
      website: supplier.website,
      integration_type: supplier.integration_type
    }
  end
end 