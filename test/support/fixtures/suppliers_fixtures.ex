defmodule Resolvinator.SuppliersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Resolvinator.Suppliers` context.
  """

  @doc """
  Generate a supplier.
  """
  def supplier_fixture(attrs \\ %{}) do
    {:ok, supplier} =
      attrs
      |> Enum.into(%{
        contact_info: %{},
        description: "some description",
        metadata: %{},
        name: "some name",
        rating: 42,
        status: "some status"
      })
      |> Resolvinator.Suppliers.create_supplier()

    supplier
  end
end
