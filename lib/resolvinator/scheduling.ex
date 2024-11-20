defmodule Resolvinator.Scheduling do
  @moduledoc """
  The Scheduling context handles time blocks, scheduling preferences, and calendar integration.
  """

  import Ecto.Query, warn: false
  alias Resolvinator.Repo
  alias Resolvinator.Calendar
  alias Resolvinator.Calendar.Integration
  alias Resolvinator.Scheduling.TimeBlock

  @doc """
  Creates a time block and syncs it with the calendar.
  """
  def create_time_block(attrs \\ %{}) do
    case %TimeBlock{}
         |> TimeBlock.changeset(attrs)
         |> Repo.insert() do
      {:ok, time_block} ->
        # Create calendar event
        if time_block.user_id do
          calendar_system = Calendar.get_default_calendar_system(time_block.user_id)
          event = create_calendar_event(time_block, calendar_system.id)
          update_time_block(time_block, %{calendar_event_id: event.id})
        else
          {:ok, time_block}
        end

      error ->
        error
    end
  end

  @doc """
  Updates a time block and syncs changes with the calendar.
  """
  def update_time_block(%TimeBlock{} = time_block, attrs) do
    case time_block
         |> TimeBlock.changeset(attrs)
         |> Repo.update() do
      {:ok, time_block} ->
        # Update calendar event
        if time_block.calendar_event_id do
          calendar_system = Calendar.get_default_calendar_system(time_block.user_id)
          update_calendar_event(time_block, calendar_system.id)
        end
        {:ok, time_block}

      error ->
        error
    end
  end

  @doc """
  Deletes a time block and its calendar event.
  """
  def delete_time_block(%TimeBlock{} = time_block) do
    # Delete calendar event if it exists
    if time_block.calendar_event_id do
      Calendar.delete_event(time_block.calendar_event_id)
    end
    Repo.delete(time_block)
  end

  @doc """
  Returns a list of time blocks for a specific date range.
  """
  def list_time_blocks(user_id, start_date, end_date) do
    TimeBlock
    |> where([b], b.user_id == ^user_id)
    |> where([b], b.start_time >= ^start_date and b.end_time <= ^end_date)
    |> order_by([b], b.start_time)
    |> Repo.all()
  end

  @doc """
  Returns all time blocks for a task.
  """
  def list_task_time_blocks(task_id) do
    TimeBlock
    |> where([b], b.task_id == ^task_id)
    |> order_by([b], b.start_time)
    |> Repo.all()
  end

  @doc """
  Returns all time blocks for a project.
  """
  def list_project_time_blocks(project_id) do
    TimeBlock
    |> where([b], b.project_id == ^project_id)
    |> order_by([b], b.start_time)
    |> Repo.all()
  end

  @doc """
  Suggests time blocks for a task based on scheduling preferences.
  """
  def suggest_time_blocks(task, date, count \\ 3) do
    # Get user's schedule for the date
    existing_blocks = list_time_blocks(task.user_id, date, Date.add(date, 1))

    # Find available time slots based on preferences
    available_slots = find_available_slots(existing_blocks, date)

    # Score slots based on task preferences and user's energy patterns
    scored_slots = score_time_slots(available_slots, task)

    # Return top suggestions
    scored_slots
    |> Enum.sort_by(fn {_slot, score} -> score end, :desc)
    |> Enum.take(count)
    |> Enum.map(fn {slot, _score} -> slot end)
  end

  # Private functions

  defp create_calendar_event(time_block, calendar_system_id) do
    Calendar.create_event(%{
      title: time_block.title,
      description: time_block.description,
      start_time: time_block.start_time,
      end_time: time_block.end_time,
      user_id: time_block.user_id,
      calendar_system_id: calendar_system_id,
      metadata: %{
        "block_type" => time_block.block_type,
        "time_block_id" => time_block.id,
        "task_id" => time_block.task_id,
        "project_id" => time_block.project_id
      }
    })
  end

  defp update_calendar_event(time_block, calendar_system_id) do
    Calendar.update_event(time_block.calendar_event_id, %{
      title: time_block.title,
      description: time_block.description,
      start_time: time_block.start_time,
      end_time: time_block.end_time,
      metadata: %{
        "block_type" => time_block.block_type,
        "time_block_id" => time_block.id,
        "task_id" => time_block.task_id,
        "project_id" => time_block.project_id
      }
    })
  end

  defp find_available_slots(existing_blocks, date) do
    work_start = ~T[09:00:00]
    work_end = ~T[17:00:00]
    min_slot_duration = 30 # minutes

    # Convert date and existing blocks to time slots
    start_time = NaiveDateTime.new!(date, work_start)
    end_time = NaiveDateTime.new!(date, work_end)

    # Sort blocks by start time
    sorted_blocks = Enum.sort_by(existing_blocks, & &1.start_time)

    # Find gaps between blocks
    find_gaps(sorted_blocks, start_time, end_time, min_slot_duration)
  end

  defp find_gaps(blocks, start_time, end_time, min_duration) do
    blocks
    |> Enum.reduce([{start_time, nil}], fn block, [{current_start, _} | _] = acc ->
      if NaiveDateTime.diff(block.start_time, current_start, :minute) >= min_duration do
        [{block.end_time, nil}, {current_start, block.start_time} | acc]
      else
        [{block.end_time, nil} | acc]
      end
    end)
    |> case do
      [{last_end, nil} | slots] ->
        if NaiveDateTime.diff(end_time, last_end, :minute) >= min_duration do
          [{last_end, end_time} | slots]
        else
          slots
        end
      [] ->
        [{start_time, end_time}]
    end
    |> Enum.reverse()
    |> Enum.reject(fn {_start, end_t} -> is_nil(end_t) end)
  end

  defp score_time_slots(slots, task) do
    Enum.map(slots, fn {start_time, end_time} = slot ->
      score = calculate_slot_score(slot, task)
      {slot, score}
    end)
  end

  defp calculate_slot_score({start_time, _end_time} = slot, task) do
    base_score = 1.0

    # Score based on preferred time of day
    time_of_day_score = case {start_time.hour, task.preferred_time_of_day} do
      {h, "morning"} when h in 9..11 -> 1.0
      {h, "afternoon"} when h in 12..14 -> 1.0
      {h, "evening"} when h in 15..17 -> 1.0
      _ -> 0.5
    end

    # Score based on energy level match
    energy_score = case {start_time.hour, task.energy_level_required} do
      {h, "high"} when h in 9..11 -> 1.0
      {h, "medium"} when h in 12..14 -> 1.0
      {h, "low"} when h in 15..17 -> 1.0
      _ -> 0.7
    end

    # Score based on focus level match
    focus_score = case {start_time.hour, task.focus_level_required} do
      {h, "high"} when h in 9..11 -> 1.0
      {h, "medium"} when h in 12..15 -> 1.0
      {h, "low"} when h in 16..17 -> 1.0
      _ -> 0.7
    end

    # Calculate final score
    base_score * time_of_day_score * energy_score * focus_score
  end
end
