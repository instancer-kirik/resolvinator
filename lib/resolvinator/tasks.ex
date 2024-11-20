defmodule Resolvinator.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo
  alias Resolvinator.Calendar
  alias Resolvinator.Calendar.Integration
  alias Resolvinator.Tasks.Task

  @doc """
  Returns the list of tasks.
  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.
  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.
  """
  def create_task(attrs \\ %{}) do
    case %Task{}
         |> Task.changeset(attrs)
         |> Repo.insert() do
      {:ok, task} ->
        # Create calendar event for deadline if present
        if task.user_id do
          calendar_system = Calendar.get_default_calendar_system(task.user_id)
          Integration.create_task_deadline(task, calendar_system.id)
        end
        {:ok, task}

      error ->
        error
    end
  end

  @doc """
  Updates a task.
  """
  def update_task(%Task{} = task, attrs) do
    case task
         |> Task.changeset(attrs)
         |> Repo.update() do
      {:ok, task} ->
        # Update calendar event if deadline changed
        if Map.has_key?(attrs, :deadline) and task.user_id do
          calendar_system = Calendar.get_default_calendar_system(task.user_id)
          Integration.update_task_deadline(task, calendar_system.id)
        end
        {:ok, task}

      error ->
        error
    end
  end

  @doc """
  Deletes a task.
  """
  def delete_task(%Task{} = task) do
    # Remove calendar events before deleting task
    Integration.delete_task_events(task.id)
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.
  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Lists tasks for a project.
  """
  def list_project_tasks(project_id) do
    Task
    |> where([t], t.project_id == ^project_id)
    |> Repo.all()
  end

  @doc """
  Lists tasks for a user.
  """
  def list_user_tasks(user_id) do
    Task
    |> where([t], t.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Lists overdue tasks for a user.
  """
  def list_overdue_tasks(user_id) do
    today = Date.utc_today()

    Task
    |> where([t], t.user_id == ^user_id)
    |> where([t], t.deadline < ^today)
    |> where([t], t.status != "completed")
    |> Repo.all()
  end

  @doc """
  Lists upcoming tasks for a user within the next n days.
  """
  def list_upcoming_tasks(user_id, days \\ 7) do
    today = Date.utc_today()
    deadline = Date.add(today, days)

    Task
    |> where([t], t.user_id == ^user_id)
    |> where([t], t.deadline >= ^today and t.deadline <= ^deadline)
    |> where([t], t.status != "completed")
    |> Repo.all()
  end
end
