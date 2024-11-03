defmodule Resolvinator.Requirements do
  @moduledoc """
  The Requirements context.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo

  alias Resolvinator.Requirements.Requirement

  @doc """
  Returns the list of requirements.

  ## Examples

      iex> list_requirements()
      [%Requirement{}, ...]

  """
  def list_requirements do
    Repo.all(Requirement)
  end

  @doc """
  Gets a single requirement.

  Raises `Ecto.NoResultsError` if the Requirement does not exist.

  ## Examples

      iex> get_requirement!(123)
      %Requirement{}

      iex> get_requirement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_requirement!(id), do: Repo.get!(Requirement, id)

  @doc """
  Creates a requirement.

  ## Examples

      iex> create_requirement(%{field: value})
      {:ok, %Requirement{}}

      iex> create_requirement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_requirement(attrs \\ %{}) do
    %Requirement{}
    |> Requirement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a requirement.

  ## Examples

      iex> update_requirement(requirement, %{field: new_value})
      {:ok, %Requirement{}}

      iex> update_requirement(requirement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_requirement(%Requirement{} = requirement, attrs) do
    requirement
    |> Requirement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a requirement.

  ## Examples

      iex> delete_requirement(requirement)
      {:ok, %Requirement{}}

      iex> delete_requirement(requirement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_requirement(%Requirement{} = requirement) do
    Repo.delete(requirement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking requirement changes.

  ## Examples

      iex> change_requirement(requirement)
      %Ecto.Changeset{data: %Requirement{}}

  """
  def change_requirement(%Requirement{} = requirement, attrs \\ %{}) do
    Requirement.changeset(requirement, attrs)
  end
end
