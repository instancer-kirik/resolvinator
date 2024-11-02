defmodule Resolvinator.Gestures do
  @moduledoc """
  The Gestures context.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo



  alias Resolvinator.Content.{Gesture, UserHiddenDescription, Description}
#alias Resolvinator.Content.{Gesture, UserHiddenDescription, GestureDescription}  




  def list_gestures(user_id) do
    hidden_description_ids =
      from(u in UserHiddenDescription, where: u.user_id == ^user_id, select: u.description_id)
      |> Repo.all()

    gestures_query =
      from(g in Gesture,
        left_join: d in Description,
        on: d.descriptionable_id == g.id and d.descriptionable_type == "Gesture",
        preload: [descriptions: d]
      )

    gestures = Repo.all(gestures_query)

    Enum.map(gestures, fn gesture ->
      filtered_descriptions =
        Enum.reject(gesture.descriptions, fn d ->
          d.id in hidden_description_ids
        end)

      %{gesture | descriptions: filtered_descriptions}
    end)
  end

  @doc """
  Returns the list of gestures.

  ## Examples

      iex> list_gestures()
      [%Gesture{}, ...]

  """
  def list_gestures do
    Repo.all(Gesture, preload: [:descriptions])
  end

  @doc """
  Gets a single gesture.

  Raises `Ecto.NoResultsError` if the Gesture does not exist.

  ## Examples

      iex> get_gesture!(123)
      %Gesture{}

      iex> get_gesture!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gesture!(id), do: Repo.get!(Gesture, id)

  @doc """
  Creates a gesture.

  ## Examples

      iex> create_gesture(%{field: value})
      {:ok, %Gesture{}}

      iex> create_gesture(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_gesture(attrs \\ %{}) do
    %Gesture{}
    |> Gesture.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a gesture.

  ## Examples

      iex> update_gesture(gesture, %{field: new_value})
      {:ok, %Gesture{}}

      iex> update_gesture(gesture, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_gesture(%Gesture{} = gesture, attrs) do
    gesture
    |> Gesture.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a gesture.

  ## Examples

      iex> delete_gesture(gesture)
      {:ok, %Gesture{}}

      iex> delete_gesture(gesture)
      {:error, %Ecto.Changeset{}}

  """
  def delete_gesture(%Gesture{} = gesture) do
    Repo.delete(gesture)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gesture changes.

  ## Examples

      iex> change_gesture(gesture)
      %Ecto.Changeset{data: %Gesture{}}

  """
  def change_gesture(%Gesture{} = gesture, attrs \\ %{}) do
    Gesture.changeset(gesture, attrs)
  end
end
