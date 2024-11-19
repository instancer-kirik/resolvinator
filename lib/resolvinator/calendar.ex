defmodule Resolvinator.Calendar do
  @moduledoc """
  Handles calendar operations and integration with TimeTracker.
  """

  require Logger
  alias TimeTracker.Calendar
  alias TimeTracker.Calendar.Event
  alias TimeTracker.Repo

  @doc """
  Parses an ICS file and sends events to TimeTracker.
  Returns {:ok, events} on success, {:error, reason} on failure.
  """
  def process_ics_file(file_path, user_id) do
    with {:ok, content} <- File.read(file_path),
         {:ok, events} <- parse_ics_content(content),
         {:ok, _} <- create_events(events, user_id) do
      {:ok, events}
    else
      error ->
        Logger.error("Failed to process ICS file: #{inspect(error)}")
        error
    end
  end

  @doc """
  Parses ICS content directly and sends events to TimeTracker.
  """
  def process_ics_content(content, user_id) do
    with {:ok, events} <- parse_ics_content(content),
         {:ok, created_events} <- create_events(events, user_id) do
      {:ok, created_events}
    end
  end

  defp parse_ics_content(content) do
    case ICalendar.from_ics(content) do
      {:ok, events} when is_list(events) ->
        {:ok, Enum.map(events, &format_event/1)}
      error ->
        {:error, "Failed to parse ICS content: #{inspect(error)}"}
    end
  end

  defp format_event(event) do
    %{
      title: event.summary || "Untitled Event",
      description: event.description || "",
      start_time: event.dtstart,
      end_time: event.dtend,
      metadata: %{
        location: event.location,
        categories: event.categories || [],
        uid: event.uid || Ecto.UUID.generate()
      }
    }
  end

  defp create_events(events, user_id) do
    # Get the default calendar system for the user
    calendar_system = Calendar.get_default_calendar_system()

    results = Enum.map(events, fn event ->
      attrs = %{
        title: event.title,
        description: event.description,
        start_time: event.start_time,
        end_time: event.end_time,
        user_id: user_id,
        calendar_system_id: calendar_system.id
      }

      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert()
    end)

    case Enum.split_with(results, fn
      {:ok, _} -> true
      {:error, _} -> false
    end) do
      {successes, []} -> {:ok, Enum.map(successes, fn {:ok, event} -> event end)}
      {_, failures} -> {:error, "Failed to create some events: #{inspect(failures)}"}
    end
  end
end
