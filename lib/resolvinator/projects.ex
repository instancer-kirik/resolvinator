defmodule Resolvinator.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo

  alias Resolvinator.Projects.{Project, OwnershipToken}

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Gets a project by name.

  ## Examples

      iex> get_project_by_name("Mathematics Learning Platform")
      %Project{}

      iex> get_project_by_name("Non-existent Project")
      nil

  """
  def get_project_by_name(name) do
    Repo.get_by(Project, name: name)
  end

  @doc """
  Claims ownership of a project for a user.

  ## Examples

      iex> claim_project(project, user)
      {:ok, %Project{}}

      iex> claim_project(project, user)
      {:error, %Ecto.Changeset{}}

  """
  def claim_project(%Project{} = project, user_id) when is_binary(user_id) do
    if is_nil(project.creator_id) do
      project
      |> Project.changeset(%{creator_id: user_id})
      |> Repo.update()
    else
      {:error, :already_claimed}
    end
  end

  @doc """
  Claims ownership of a project using a token.
  Returns {:ok, project} if successful, {:error, reason} otherwise.
  """
  def claim_project_with_token(%Project{} = project, token, user_id) when is_binary(user_id) do
    with :ok <- OwnershipToken.verify_token_hash(token, project.ownership_token_hash, project),
         {:ok, project} <- claim_project(project, user_id) do
      # Clear the token after successful claim
      project
      |> Project.ownership_token_changeset(nil)
      |> Repo.update()
    end
  end

  @doc """
  Generates a new ownership token for a project.
  Returns {token, project} where token is the string to be shared.
  """
  def generate_ownership_token(%Project{} = project) do
    {token, hash} = OwnershipToken.generate_token_pair(project)
    
    {:ok, project} =
      project
      |> Project.ownership_token_changeset(hash)
      |> Repo.update()

    {token, project}
  end
end
