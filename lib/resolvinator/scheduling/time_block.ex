defmodule Resolvinator.Scheduling.TimeBlock do
  use Resolvinator.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Acts.User
  alias Acts.Profiles.ResolvinatorProfile
  alias Resolvinator.Scheduling.Task
  alias Resolvinator.Projects.Project

  schema "time_blocks" do
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :title, :string
    field :description, :string
    field :block_type, :string  # "work", "break", "meeting", "focus", etc.
    field :recurrence_rule, :string  # iCal RRULE format
    field :status, :string, default: "scheduled"  # scheduled, in_progress, completed, cancelled
    field :calendar_event_id, :string  # Reference to TimeTracker calendar event

    # Scheduling preferences
    field :preferred_time_of_day, :string  # morning, afternoon, evening
    field :energy_level_required, :string  # high, medium, low
    field :focus_level_required, :string  # high, medium, low
    field :buffer_before, :integer  # minutes
    field :buffer_after, :integer   # minutes

    belongs_to :user, User
    belongs_to :resolvinator_profile, ResolvinatorProfile
    belongs_to :task, Task
    belongs_to :project, Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(time_block, attrs) do
    time_block
    |> cast(attrs, [
      :start_time, :end_time, :duration_minutes, :task_id, :status
    ])
    |> validate_required([:start_time, :end_time, :duration_minutes, :task_id])
    |> validate_inclusion(:status, ["scheduled", "in_progress", "completed", "cancelled"])
    |> validate_time_range()
    |> validate_buffers()
  end

  defp validate_time_range(changeset) do
    case {get_field(changeset, :start_time), get_field(changeset, :end_time)} do
      {start_time, end_time} when not is_nil(start_time) and not is_nil(end_time) ->
        if DateTime.compare(end_time, start_time) == :gt do
          changeset
        else
          add_error(changeset, :end_time, "must be after start time")
        end
      _ ->
        changeset
    end
  end

  defp validate_buffers(changeset) do
    case get_field(changeset, :duration_minutes) do
      duration_minutes when not is_nil(duration_minutes) ->
        if duration_minutes >= 0 do
          changeset
        else
          add_error(changeset, :duration_minutes, "must be non-negative")
        end
      _ ->
        changeset
    end
  end
end
