defmodule Resolvinator.Actors do
  @moduledoc """
  The Actors context.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo

  alias Resolvinator.Actors.Actor

  @doc """
  Returns the list of actors.

  ## Examples

      iex> list_actors()
      [%Actor{}, ...]

  """
  def list_actors do
    Repo.all(Actor)
  end

  @doc """
  Gets a single actor.

  Raises `Ecto.NoResultsError` if the Actor does not exist.

  ## Examples

      iex> get_actor!(123)
      %Actor{}

      iex> get_actor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_actor!(id), do: Repo.get!(Actor, id)

  @doc """
  Creates a actor.

  ## Examples

      iex> create_actor(%{field: value})
      {:ok, %Actor{}}

      iex> create_actor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_actor(attrs \\ %{}) do
    %Actor{}
    |> Actor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a actor.

  ## Examples

      iex> update_actor(actor, %{field: new_value})
      {:ok, %Actor{}}

      iex> update_actor(actor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_actor(%Actor{} = actor, attrs) do
    actor
    |> Actor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a actor.

  ## Examples

      iex> delete_actor(actor)
      {:ok, %Actor{}}

      iex> delete_actor(actor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_actor(%Actor{} = actor) do
    Repo.delete(actor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking actor changes.

  ## Examples

      iex> change_actor(actor)
      %Ecto.Changeset{data: %Actor{}}

  """
  def change_actor(%Actor{} = actor, attrs \\ %{}) do
    Actor.changeset(actor, attrs)
  end

  @doc """
  Lists actors for a specific project with optional filtering and pagination.
  """
  def list_project_actors(project_id, opts \\ []) do
    page = Keyword.get(opts, :page, %{"number" => "1", "size" => "20"})
    includes = Keyword.get(opts, :includes, [])
    filters = Keyword.get(opts, :filters, %{})
    sort = Keyword.get(opts, :sort)

    Actor
    |> where([a], a.project_id == ^project_id)
    |> apply_filters(filters)
    |> apply_sorting(sort)
    |> handle_includes(includes)
    |> paginate(page)
  end

  # Helper functions for filtering, sorting, and pagination
  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {"type", value}, query -> where(query, [a], a.type == ^value)
      {"status", value}, query -> where(query, [a], a.status == ^value)
      _, query -> query
    end)
  end

  defp apply_sorting(query, nil), do: query
  defp apply_sorting(query, "name"), do: order_by(query, [a], a.name)
  defp apply_sorting(query, "-name"), do: order_by(query, [a], [desc: a.name])
  defp apply_sorting(query, _), do: query

  defp handle_includes(query, includes) do
    Enum.reduce(includes, query, fn
      "project", query -> preload(query, :project)
      _, query -> query
    end)
  end

  defp paginate(query, %{"number" => page_number, "size" => page_size}) do
    page_number = String.to_integer(page_number)
    page_size = String.to_integer(page_size)
    offset = (page_number - 1) * page_size

    {Repo.all(query |> limit(^page_size) |> offset(^offset)),
     %{
       page_number: page_number,
       page_size: page_size,
       total_entries: Repo.aggregate(query, :count, :id),
       total_pages: ceil(Repo.aggregate(query, :count, :id) / page_size)
     }}
  end

  @doc """
  Gets a single actor for a specific project.
  Raises `Ecto.NoResultsError` if the Actor does not exist in the project.
  """
  def get_project_actor!(project_id, id) do
    Actor
    |> where([a], a.project_id == ^project_id and a.id == ^id)
    |> Repo.one!()
  end
end
