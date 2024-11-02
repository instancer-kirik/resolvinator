defmodule Resolvinator.Risks do
  @moduledoc """
  The Risks context.
  """
  @cacheable_queries [:list_project_risks, :get_project_risk!]
  @cache_ttl :timer.minutes(5)
  import Resolvinator.QueryHelpers, only: [
    paginate: 2,
    handle_includes: 2,
    apply_filters: 2,
    apply_sorting: 2,
    exclude_hidden: 1,
    include_hidden: 1,
    only_hidden: 1
  ]

  import Ecto.Query, warn: false
  alias Resolvinator.Repo

  alias Resolvinator.Risks.Category

  @doc """
  Returns the list of risk_categories.

  ## Examples

      iex> list_risk_categories()
      [%Category{}, ...]

  """
  def list_risk_categories(opts \\ []) do
    Category
    |> apply_hidden_filter(opts[:show_hidden])
    |> Repo.all()
  end

  defp apply_hidden_filter(query, show_hidden) do
    case show_hidden do
      true -> include_hidden(query)
      :only -> only_hidden(query)
      _ -> exclude_hidden(query)
    end
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Resolvinator.Risks.Risk

  @doc """
  Returns the list of risks.

  ## Examples

      iex> list_risks()
      [%Risk{}, ...]

  """
  def list_risks do
    Repo.all(Risk)
  end

  @doc """
  Gets a single risk.

  Raises `Ecto.NoResultsError` if the Risk does not exist.

  ## Examples

      iex> get_risk!(123)
      %Risk{}

      iex> get_risk!(456)
      ** (Ecto.NoResultsError)

  """
  def get_risk!(id), do: Repo.get!(Risk, id)

  @doc """
  Creates a risk.

  ## Examples

      iex> create_risk(%{field: value})
      {:ok, %Risk{}}

      iex> create_risk(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_risk(attrs \\ %{}) do
    %Risk{}
    |> Risk.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:risk, :created])
  end

  @doc """
  Updates a risk.

  ## Examples

      iex> update_risk(risk, %{field: new_value})
      {:ok, %Risk{}}

      iex> update_risk(risk, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_risk(%Risk{} = risk, attrs) do
    risk
    |> Risk.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:risk, :updated])
  end

  @doc """
  Deletes a risk.

  ## Examples

      iex> delete_risk(risk)
      {:ok, %Risk{}}

      iex> delete_risk(risk)
      {:error, %Ecto.Changeset{}}

  """
  def delete_risk(%Risk{} = risk) do
    Repo.delete(risk)
    |> notify_subscribers([:risk, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking risk changes.

  ## Examples

      iex> change_risk(risk)
      %Ecto.Changeset{data: %Risk{}}

  """
  def change_risk(%Risk{} = risk, attrs \\ %{}) do
    Risk.changeset(risk, attrs)
  end

  alias Resolvinator.Risks.Impact

  @doc """
  Returns the list of impacts.

  ## Examples

      iex> list_impacts()
      [%Impact{}, ...]

  """
  def list_impacts(risk_id, opts \\ []) do
    cache_key = {:impacts, risk_id, opts}

    Cachex.fetch(:resolvinator_cache, cache_key, fn ->
      {impacts, page_info} = do_list_impacts(risk_id, opts)
      {:commit, {impacts, page_info}, ttl: @cache_ttl}
    end)
  end

  defp do_list_impacts(risk_id, opts) do
    page = Keyword.get(opts, :page, %{"number" => "1", "size" => "20"})
    includes = Keyword.get(opts, :includes, [])

    Impact
    |> where([i], i.risk_id == ^risk_id)
    |> handle_includes(includes)
    |> paginate(page)
    |> Repo.all()
  end

  @doc """
  Gets a single impact.

  Raises `Ecto.NoResultsError` if the Impact does not exist.

  ## Examples

      iex> get_impact!(123)
      %Impact{}

      iex> get_impact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_impact!(risk_id, id, includes \\ []) do
    cache_key = {:impact, risk_id, id, includes}

    Cachex.fetch(:resolvinator_cache, cache_key, fn ->
      impact = do_get_impact!(risk_id, id, includes)
      {:commit, impact, ttl: @cache_ttl}
    end)
  end

  defp do_get_impact!(risk_id, id, includes) do
    Impact
    |> where([i], i.risk_id == ^risk_id and i.id == ^id)
    |> handle_includes(includes)
    |> Repo.one!()
  end

  @doc """
  Creates a impact.

  ## Examples

      iex> create_impact(%{field: value})
      {:ok, %Impact{}}

      iex> create_impact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_impact(attrs \\ %{}) do
    %Impact{}
    |> Impact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a impact.

  ## Examples

      iex> update_impact(impact, %{field: new_value})
      {:ok, %Impact{}}

      iex> update_impact(impact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_impact(%Impact{} = impact, attrs) do
    impact
    |> Impact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a impact.

  ## Examples

      iex> delete_impact(impact)
      {:ok, %Impact{}}

      iex> delete_impact(impact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_impact(%Impact{} = impact) do
    Repo.delete(impact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking impact changes.

  ## Examples

      iex> change_impact(impact)
      %Ecto.Changeset{data: %Impact{}}

  """
  def change_impact(%Impact{} = impact, attrs \\ %{}) do
    Impact.changeset(impact, attrs)
  end

  alias Resolvinator.Risks.Mitigation

  @doc """
  Returns the list of mitigations.

  ## Examples

      iex> list_mitigations()
      [%Mitigation{}, ...]

  """
  def list_mitigations do
    Repo.all(Mitigation)
  end

  @doc """
  Gets a single mitigation.

  Raises `Ecto.NoResultsError` if the Mitigation does not exist.

  ## Examples

      iex> get_mitigation!(123)
      %Mitigation{}

      iex> get_mitigation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mitigation!(id), do: Repo.get!(Mitigation, id)

  @doc """
  Creates a mitigation.

  ## Examples

      iex> create_mitigation(%{field: value})
      {:ok, %Mitigation{}}

      iex> create_mitigation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mitigation(attrs \\ %{}) do
    %Mitigation{}
    |> Mitigation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mitigation.

  ## Examples

      iex> update_mitigation(mitigation, %{field: new_value})
      {:ok, %Mitigation{}}

      iex> update_mitigation(mitigation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mitigation(%Mitigation{} = mitigation, attrs) do
    mitigation
    |> Mitigation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mitigation.

  ## Examples

      iex> delete_mitigation(mitigation)
      {:ok, %Mitigation{}}

      iex> delete_mitigation(mitigation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mitigation(%Mitigation{} = mitigation) do
    Repo.delete(mitigation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mitigation changes.

  ## Examples

      iex> change_mitigation(mitigation)
      %Ecto.Changeset{data: %Mitigation{}}

  """
  def change_mitigation(%Mitigation{} = mitigation, attrs \\ %{}) do
    Mitigation.changeset(mitigation, attrs)
  end

  alias Resolvinator.Risks.MitigationTask

  @doc """
  Returns the list of mitigation_tasks.

  ## Examples

      iex> list_mitigation_tasks()
      [%MitigationTask{}, ...]

  """
  def list_mitigation_tasks do
    Repo.all(MitigationTask)
  end

  @doc """
  Gets a single mitigation_task.

  Raises `Ecto.NoResultsError` if the Mitigation task does not exist.

  ## Examples

      iex> get_mitigation_task!(123)
      %MitigationTask{}

      iex> get_mitigation_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mitigation_task!(id), do: Repo.get!(MitigationTask, id)

  @doc """
  Creates a mitigation_task.

  ## Examples

      iex> create_mitigation_task(%{field: value})
      {:ok, %MitigationTask{}}

      iex> create_mitigation_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mitigation_task(attrs \\ %{}) do
    %MitigationTask{}
    |> MitigationTask.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mitigation_task.

  ## Examples

      iex> update_mitigation_task(mitigation_task, %{field: new_value})
      {:ok, %MitigationTask{}}

      iex> update_mitigation_task(mitigation_task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mitigation_task(%MitigationTask{} = mitigation_task, attrs) do
    mitigation_task
    |> MitigationTask.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mitigation_task.

  ## Examples

      iex> delete_mitigation_task(mitigation_task)
      {:ok, %MitigationTask{}}

      iex> delete_mitigation_task(mitigation_task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mitigation_task(%MitigationTask{} = mitigation_task) do
    Repo.delete(mitigation_task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mitigation_task changes.

  ## Examples

      iex> change_mitigation_task(mitigation_task)
      %Ecto.Changeset{data: %MitigationTask{}}

  """
  def change_mitigation_task(%MitigationTask{} = mitigation_task, attrs \\ %{}) do
    MitigationTask.changeset(mitigation_task, attrs)
  end
  

  @doc """
  Lists project risks with caching support.
  """
  def list_project_risks(project_id, opts \\ []) do
    case Cachex.get(:resolvinator_cache, {:risks, project_id, opts}) do
      {:ok, nil} ->
        # Cache miss - fetch and cache the result
        result = do_list_project_risks(project_id, opts)
        Cachex.put(:resolvinator_cache, {:risks, project_id, opts}, result, ttl: @cache_ttl)
        result
      {:ok, value} ->
        # Cache hit
        value
      {:error, _} ->
        # On error, just fetch without caching
        do_list_project_risks(project_id, opts)
    end
  end

  defp do_list_project_risks(project_id, opts) do
    page = Keyword.get(opts, :page, %{"number" => "1", "size" => "20"})
    includes = Keyword.get(opts, :includes, [])
    filters = Keyword.get(opts, :filters, %{})
    sort = Keyword.get(opts, :sort)

    query = Risk
            |> where([r], r.project_id == ^project_id)
            |> apply_filters(filters)
            |> apply_sorting(sort)
            |> handle_includes(includes)

    {results, page_info} = paginate(query, page)
    {results, page_info}
  end

  @doc """
  Gets a project risk with caching support.
  """
  def get_project_risk!(project_id, id, includes \\ []) do
    case Cachex.get(:resolvinator_cache, {:risk, project_id, id, includes}) do
      {:ok, nil} ->
        result = do_get_project_risk!(project_id, id, includes)
        Cachex.put(:resolvinator_cache, {:risk, project_id, id, includes}, result, ttl: @cache_ttl)
        result
      {:ok, value} ->
        value
      {:error, _} ->
        do_get_project_risk!(project_id, id, includes)
    end
  end

  defp do_get_project_risk!(project_id, id, includes) do
    Risk
    |> where([r], r.project_id == ^project_id and r.id == ^id)
    |> handle_includes(includes)
    |> Repo.one!()
  end

  defp notify_subscribers({:ok, risk} = result, event) do
    Resolvinator.PubSub.broadcast("risks:#{risk.project_id}", {event, risk})
    result
  end
  defp notify_subscribers(error, _), do: error

  def hide_category(%Category{} = category, user_id) do
    category
    |> Category.hide(user_id)
    |> Repo.update()
    |> notify_subscribers({:category_hidden, category})
  end

  def unhide_category(%Category{} = category) do
    category
    |> Category.unhide()
    |> Repo.update()
    |> notify_subscribers({:category_unhidden, category})
  end
end
