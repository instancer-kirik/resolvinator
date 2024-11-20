defmodule Resolvinator.Calendar.Integration do
  @moduledoc """
  Handles calendar integration and event management.
  """

  import Ecto.Query

  alias Resolvinator.Repo
  alias Resolvinator.Calendar.Event
  alias Resolvinator.Projects.Project
  alias Resolvinator.Calendar
  alias TimeTracker.Calendar.Event, as: TimeTrackerEvent

  @doc """
  sync_project_dates/2 creates calendar events for a project.
  """
  def sync_project_dates(%Project{} = project, calendar_system_id) do
    events = []

    # Add start date event
    events =
      if project.start_date do
        [
          %{
            title: "Project Start: #{project.name}",
            description: project.description,
            start_time: DateTime.new!(project.start_date, ~T[00:00:00]),
            end_time: DateTime.new!(project.start_date, ~T[23:59:59]),
            user_id: project.user_id,
            calendar_system_id: calendar_system_id,
            metadata: %{
              "event_type" => "project_start",
              "project_id" => project.id
            }
          }
          | events
        ]
      else
        events
      end

    # Add target date event
    events =
      if project.target_date do
        [
          %{
            title: "Project Target Date: #{project.name}",
            description: project.description,
            start_time: DateTime.new!(project.target_date, ~T[00:00:00]),
            end_time: DateTime.new!(project.target_date, ~T[23:59:59]),
            user_id: project.user_id,
            calendar_system_id: calendar_system_id,
            metadata: %{
              "event_type" => "project_target",
              "project_id" => project.id
            }
          }
          | events
        ]
      else
        events
      end

    # Add completion date event
    events =
      if project.completion_date do
        [
          %{
            title: "Project Completed: #{project.name}",
            description: project.description,
            start_time: DateTime.new!(project.completion_date, ~T[00:00:00]),
            end_time: DateTime.new!(project.completion_date, ~T[23:59:59]),
            user_id: project.user_id,
            calendar_system_id: calendar_system_id,
            metadata: %{
              "event_type" => "project_completion",
              "project_id" => project.id
            }
          }
          | events
        ]
      else
        events
      end

    # Create all events
    Enum.each(events, &Calendar.create_event/1)
  end

  @doc """
  Updates calendar events when project dates change.
  """
  def update_project_dates(%Project{} = project, calendar_system_id) do
    # First remove old events
    delete_project_events(project.id)
    # Then create new ones
    sync_project_dates(project, calendar_system_id)
  end

  @doc """
  Deletes all calendar events associated with a project.
  """
  def delete_project_events(project_id) do
    query =
      from e in TimeTrackerEvent,
        where: fragment("(?->>'project_id')::text = ?", e.metadata, ^project_id)

    TimeTracker.Repo.delete_all(query)
  end

  @doc """
  Creates a calendar event for a task deadline.
  """
  def create_task_deadline(task, calendar_system_id) do
    if task.deadline do
      Calendar.create_event(%{
        title: "Task Due: #{task.title}",
        description: task.description,
        start_time: DateTime.new!(task.deadline, ~T[00:00:00]),
        end_time: DateTime.new!(task.deadline, ~T[23:59:59]),
        user_id: task.user_id,
        calendar_system_id: calendar_system_id,
        metadata: %{
          "event_type" => "task_deadline",
          "task_id" => task.id,
          "project_id" => task.project_id
        }
      })
    end
  end

  @doc """
  Updates a task's deadline in the calendar.
  """
  def update_task_deadline(task, calendar_system_id) do
    # Remove old deadline
    delete_task_events(task.id)
    # Create new deadline
    create_task_deadline(task, calendar_system_id)
  end

  @doc """
  Deletes all calendar events associated with a task.
  """
  def delete_task_events(task_id) do
    query =
      from e in TimeTrackerEvent,
        where: fragment("(?->>'task_id')::text = ?", e.metadata, ^task_id)

    TimeTracker.Repo.delete_all(query)
  end
end
