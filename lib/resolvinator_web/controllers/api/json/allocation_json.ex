defmodule ResolvinatorWeb.API.AllocationJSON do
  def data(allocation, _opts \\ []) do
    %{
      id: allocation.id,
      type: "allocation",
      attributes: %{
        quantity: allocation.quantity,
        status: allocation.status,
        notes: allocation.notes,
        allocated_at: allocation.allocated_at,
        inserted_at: allocation.inserted_at,
        updated_at: allocation.updated_at
      }
    }
  end
end 