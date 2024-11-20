defmodule Resolvinator.Calendar do
  @moduledoc """
  Handles calendar operations and integration with TimeTracker.
  """

  require Logger
  alias TimeTracker.Calendar
  alias TimeTracker.Calendar.Event
  alias TimeTracker.Repo

  @doc """
  Gets the calendar data for a specific month.
  """
  def get_month_data(user_id, year, month, calendar_system_id) do
    start_date = Date.new!(year, month, 1)
    end_date = Date.new!(year, month, Date.days_in_month(start_date))

    events = Calendar.list_events(user_id, calendar_system_id, start_date, end_date)
    day_data = Calendar.list_day_data(user_id, calendar_system_id, start_date, end_date)
    daily_reminders = Calendar.list_daily_reminders(user_id, calendar_system_id)

    %{
      events: events,
      day_data: day_data,
      daily_reminders: daily_reminders,
      calendar_system: Calendar.get_calendar_system!(calendar_system_id)
    }
  end

  @doc """
  Creates a new event.
  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an event.
  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an event.
  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Gets a single event.
  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Lists events for a specific date range.
  """
  def list_events(user_id, calendar_system_id, start_date, end_date) do
    Calendar.list_events(user_id, calendar_system_id, start_date, end_date)
  end

  @doc """
  Gets the default calendar system for a user.
  """
  def get_default_calendar_system(user_id) do
    Calendar.get_default_calendar_system(user_id)
  end

  @doc """
  Formats a datetime for display.
  """
  def format_datetime(datetime) do
    Calendar.format_datetime(datetime)
  end
end
