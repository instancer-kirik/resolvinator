defmodule Resolvinator.Resources do
  import Ecto.Query
  alias Resolvinator.Repo
  alias Resolvinator.Resources.{Allocation, Requirement}
  alias Resolvinator.Resources.InventoryItems.InventoryItem

  # Allocation functions
  def list_allocations(item_id, opts \\ []) do
    page = Keyword.get(opts, :page, %{"number" => 1, "size" => 20})

    query = from a in Allocation,
      where: a.inventory_item_id == ^item_id

    paginated = Repo.paginate(query, page: page)
    {paginated.entries, %{
      total_pages: paginated.total_pages,
      total_count: paginated.total_entries,
      page_size: paginated.page_size,
      page_number: paginated.page_number
    }}
  end

  def get_allocation!(id), do: Repo.get!(Allocation, id)

  def create_allocation(attrs), do: %Allocation{} |> Allocation.changeset(attrs) |> Repo.insert()

  def update_allocation(%Allocation{} = allocation, attrs) do
    allocation |> Allocation.changeset(attrs) |> Repo.update()
  end

  def delete_allocation(%Allocation{} = allocation), do: Repo.delete(allocation)

  # Requirement functions
  def list_requirements(project_id, risk_id, mitigation_id, opts \\ []) do
    page = Keyword.get(opts, :page, %{"number" => 1, "size" => 20})

    Requirement
    |> filter_by_owner(project_id, risk_id, mitigation_id)
    |> Repo.paginate(page: page)
    |> format_pagination_results()
  end

  def get_requirement(id), do: Repo.get(Requirement, id)

  def create_requirement(attrs) do
    %Requirement{}
    |> Requirement.changeset(attrs)
    |> Repo.insert()
  end

  def update_requirement(id, attrs) do
    case get_requirement(id) do
      nil -> {:error, :not_found}
      requirement ->
        requirement
        |> Requirement.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete_requirement(id) do
    case get_requirement(id) do
      nil -> {:error, :not_found}
      requirement -> Repo.delete(requirement)
    end
  end

  # Inventory Item functions
  def list_inventory_items(project_id, opts \\ []) do
    page = Keyword.get(opts, :page, %{"number" => 1, "size" => 20})
    filters = Keyword.get(opts, :filters, %{})

    InventoryItem
    |> filter_inventory_items(project_id, filters)
    |> Repo.paginate(page: page)
    |> format_pagination_results()
  end

  def get_inventory_item(id), do: {:ok, Repo.get(InventoryItem, id)}

  def create_inventory_item(attrs) do
    %InventoryItem{}
    |> InventoryItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_inventory_item(item, attrs) do
    item
    |> InventoryItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_inventory_item(item), do: Repo.delete(item)

  # Private helper functions
  defp filter_by_owner(query, project_id, risk_id, mitigation_id) do
    query
    |> where([r], r.project_id == ^project_id or r.risk_id == ^risk_id or r.mitigation_id == ^mitigation_id)
  end

  defp filter_inventory_items(query, project_id, filters) do
    query
    |> where([i], i.project_id == ^project_id)
    |> apply_inventory_filters(filters)
  end

  defp apply_inventory_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {"status", status}, query -> where(query, [i], i.status == ^status)
      {"category", category}, query -> where(query, [i], i.category == ^category)
      _, query -> query
    end)
  end

  defp format_pagination_results(paginated) do
    {paginated.entries, %{
      total_pages: paginated.total_pages,
      total_count: paginated.total_entries,
      page_size: paginated.page_size,
      page_number: paginated.page_number
    }}
  end

  alias Resolvinator.Resources.Resource

  @doc """
  Returns the list of resources.

  ## Examples

      iex> list_resources()
      [%Resource{}, ...]

  """
  def list_resources do
    Repo.all(Resource)
  end

  @doc """
  Gets a single resource.

  Raises `Ecto.NoResultsError` if the Resource does not exist.

  ## Examples

      iex> get_resource!(123)
      %Resource{}

      iex> get_resource!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resource!(id), do: Repo.get!(Resource, id)

  @doc """
  Creates a resource.

  ## Examples

      iex> create_resource(%{field: value})
      {:ok, %Resource{}}

      iex> create_resource(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resource(attrs \\ %{}) do
    %Resource{}
    |> Resource.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a resource.

  ## Examples

      iex> update_resource(resource, %{field: new_value})
      {:ok, %Resource{}}

      iex> update_resource(resource, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resource(%Resource{} = resource, attrs) do
    resource
    |> Resource.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a resource.

  ## Examples

      iex> delete_resource(resource)
      {:ok, %Resource{}}

      iex> delete_resource(resource)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resource(%Resource{} = resource) do
    Repo.delete(resource)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resource changes.

  ## Examples

      iex> change_resource(resource)
      %Ecto.Changeset{data: %Resource{}}

  """
  def change_resource(%Resource{} = resource, attrs \\ %{}) do
    Resource.changeset(resource, attrs)
  end

  @doc """
  Lists resources for a specific project.
  """
  def list_project_resources(project_id, opts \\ []) do
    Resource
    |> where([r], r.project_id == ^project_id)
    |> preload([:rewards, :allocations])
    |> Repo.all()
  end

  @doc """
  Gets a resource with preloaded associations.
  """
  def get_resource_with_associations!(id) do
    Resource
    |> Repo.get!(id)
    |> Repo.preload([:project, :rewards, :allocations, :requirements])
  end

  @doc """
  Creates a resource with project association.
  """
  def create_project_resource(project_id, attrs) do
    %Resource{project_id: project_id}
    |> Resource.changeset(attrs)
    |> Repo.insert()
  end
end
