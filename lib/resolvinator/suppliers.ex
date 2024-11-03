defmodule Resolvinator.Suppliers do
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Suppliers.{Supplier, Contact, Catalog}

  def list_suppliers do
    Repo.all(Supplier)
  end

  def get_supplier!(id), do: Repo.get!(Supplier, id)

  def create_supplier(attrs \\ %{}) do
    %Supplier{}
    |> Supplier.changeset(attrs)
    |> Repo.insert()
  end

  def update_supplier(%Supplier{} = supplier, attrs) do
    supplier
    |> Supplier.changeset(attrs)
    |> Repo.update()
  end

  def delete_supplier(%Supplier{} = supplier) do
    Repo.delete(supplier)
  end

  def get_supplier_performance(%Supplier{} = supplier) do
    # Implement performance metrics calculation
    # This is a placeholder implementation
    %{
      on_time_delivery_rate: 95.5,
      quality_rating: 4.8,
      response_time: 24,
      supplier_id: supplier.id
    }
  end

  def get_supplier_pricing(%Supplier{} = supplier) do
    # Implement pricing data retrieval
    # This is a placeholder implementation
    %{
      standard_rates: %{},
      volume_discounts: %{},
      special_offers: [],
      supplier_id: supplier.id
    }
  end

  # Contact functions
  def list_supplier_contacts(supplier_id) do
    Contact
    |> where(supplier_id: ^supplier_id)
    |> order_by([c], [{:desc, c.primary}, {:asc, c.name}])
    |> Repo.all()
  end

  def get_contact!(id), do: Repo.get!(Contact, id)

  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  # Catalog functions
  def list_supplier_catalogs(supplier_id) do
    Catalog
    |> where(supplier_id: ^supplier_id)
    |> where([c], c.status == "active")
    |> where([c], c.effective_date <= ^Date.utc_today())
    |> where([c], is_nil(c.expiry_date) or c.expiry_date >= ^Date.utc_today())
    |> order_by([c], [desc: c.effective_date])
    |> Repo.all()
  end

  def get_catalog!(id), do: Repo.get!(Catalog, id)

  def create_catalog(attrs \\ %{}) do
    %Catalog{}
    |> Catalog.changeset(attrs)
    |> Repo.insert()
  end

  def update_catalog(%Catalog{} = catalog, attrs) do
    catalog
    |> Catalog.changeset(attrs)
    |> Repo.update()
  end

  def delete_catalog(%Catalog{} = catalog) do
    Repo.delete(catalog)
  end

  # Helper functions
  def get_active_catalogs(supplier_id) do
    today = Date.utc_today()

    Catalog
    |> where(supplier_id: ^supplier_id)
    |> where([c], c.status == "active")
    |> where([c], c.effective_date <= ^today)
    |> where([c], is_nil(c.expiry_date) or c.expiry_date >= ^today)
    |> order_by([c], [desc: c.effective_date])
    |> limit(1)
    |> Repo.one()
  end

  def get_primary_contact(supplier_id) do
    Contact
    |> where(supplier_id: ^supplier_id)
    |> where(primary: true)
    |> Repo.one()
  end

  alias Resolvinator.Suppliers.Supplier

  @doc """
  Returns the list of suppliers.

  ## Examples

      iex> list_suppliers()
      [%Supplier{}, ...]

  """
  def list_suppliers do
    Repo.all(Supplier)
  end

  @doc """
  Gets a single supplier.

  Raises `Ecto.NoResultsError` if the Supplier does not exist.

  ## Examples

      iex> get_supplier!(123)
      %Supplier{}

      iex> get_supplier!(456)
      ** (Ecto.NoResultsError)

  """
  def get_supplier!(id), do: Repo.get!(Supplier, id)



  @doc """
  Updates a supplier.

  ## Examples

      iex> update_supplier(supplier, %{field: new_value})
      {:ok, %Supplier{}}

      iex> update_supplier(supplier, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_supplier(%Supplier{} = supplier, attrs) do
    supplier
    |> Supplier.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a supplier.

  ## Examples

      iex> delete_supplier(supplier)
      {:ok, %Supplier{}}

      iex> delete_supplier(supplier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_supplier(%Supplier{} = supplier) do
    Repo.delete(supplier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking supplier changes.

  ## Examples

      iex> change_supplier(supplier)
      %Ecto.Changeset{data: %Supplier{}}

  """
  def change_supplier(%Supplier{} = supplier, attrs \\ %{}) do
    Supplier.changeset(supplier, attrs)
  end
end
