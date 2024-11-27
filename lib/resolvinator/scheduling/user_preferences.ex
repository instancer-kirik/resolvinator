defmodule Resolvinator.Scheduling.UserPreferences do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_scheduling_preferences" do
    field :work_hours, :map
    field :time_zone, :string
    field :work_days, {:array, :string}
    field :break_preferences, :map
    field :focus_time_preferences, :map
    field :energy_levels, :map
    field :block_type_colors, :map, default: %{
      "work" => "#98FB98",      # Pale green
      "meeting" => "#FFB6C1",   # Light pink
      "focus" => "#E6E6FA",     # Lavender
      "break" => "#87CEEB",     # Sky blue
      "planning" => "#DDA0DD",  # Plum
      "review" => "#F0E68C"     # Khaki
    }
    field :energy_level_colors, :map, default: %{
      "high" => "#90EE90",    # Light green
      "medium" => "#F0E68C",  # Khaki
      "low" => "#ADD8E6"      # Light blue
    }
    belongs_to :user, Acts.User
    belongs_to :default_color_palette, TimeTracker.Colors.UserColorPalette

    has_many :color_palette_assignments, Resolvinator.Scheduling.UserSchedulingPreferencesColorPalette
    has_many :color_palettes, through: [:color_palette_assignments, :user_color_palette]

    timestamps()
  end

  @required_fields [:work_hours, :time_zone, :work_days, :break_preferences, 
                   :focus_time_preferences, :energy_levels, :user_id]
  @optional_fields [:block_type_colors, :energy_level_colors, :default_color_palette_id]

  @doc false
  def changeset(preferences, attrs) do
    preferences
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_work_hours()
    |> validate_time_zone()
    |> validate_work_days()
    |> validate_break_preferences()
    |> validate_focus_time_preferences()
    |> validate_energy_levels()
    |> validate_colors()
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:default_color_palette_id)
  end

  defp validate_time_range(changeset) do
    case {get_field(changeset, :work_start_time), get_field(changeset, :work_end_time)} do
      {start_time, end_time} when not is_nil(start_time) and not is_nil(end_time) ->
        if Time.compare(end_time, start_time) == :gt do
          changeset
        else
          add_error(changeset, :work_end_time, "must be after work start time")
        end
      _ ->
        changeset
    end
  end

  defp validate_work_days(changeset) do
    case get_field(changeset, :work_days) do
      days when is_list(days) ->
        valid_days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        if Enum.all?(days, &(&1 in valid_days)) do
          changeset
        else
          add_error(changeset, :work_days, "contains invalid day names")
        end
      _ ->
        changeset
    end
  end

  defp validate_energy_hours(changeset) do
    fields = [:high_energy_hours, :medium_energy_hours, :low_energy_hours]
    
    Enum.reduce(fields, changeset, fn field, acc ->
      case get_field(acc, field) do
        hours when is_list(hours) ->
          if Enum.all?(hours, &(&1 in 0..23)) do
            acc
          else
            add_error(acc, field, "must contain valid hours (0-23)")
          end
        _ ->
          acc
      end
    end)
  end

  defp validate_break_preferences(changeset) do
    case get_field(changeset, :break_preferences) do
      prefs when is_map(prefs) ->
        valid_times? = Enum.all?(prefs, fn {_name, %{"preferred_time" => time}} ->
          case Time.from_iso8601(time <> ":00") do
            {:ok, _} -> true
            _ -> false
          end
        end)

        valid_durations? = Enum.all?(prefs, fn {_name, %{"duration" => duration}} ->
          is_integer(duration) and duration > 0
        end)

        valid_colors? = Enum.all?(prefs, fn {_name, %{"color" => color}} ->
          is_binary(color) and String.match?(color, ~r/^#[0-9A-Fa-f]{6}$/)
        end)

        if valid_times? and valid_durations? and valid_colors? do
          changeset
        else
          add_error(changeset, :break_preferences, "contains invalid time, duration, or color values")
        end
      _ ->
        changeset
    end
  end

  defp validate_focus_preferences(changeset) do
    case get_field(changeset, :focus_time_preferences) do
      %{
        "preferred_times" => times,
        "min_duration" => duration,
        "max_interruptions" => interruptions,
        "color" => color
      } = prefs when is_list(times) and is_integer(duration) and is_integer(interruptions) ->
        valid_times = ["early_morning", "late_morning", "early_afternoon", "late_afternoon"]
        valid_color? = is_binary(color) and String.match?(color, ~r/^#[0-9A-Fa-f]{6}$/)

        if Enum.all?(times, &(&1 in valid_times)) and duration > 0 and interruptions >= 0 and valid_color? do
          changeset
        else
          add_error(changeset, :focus_time_preferences, "contains invalid values")
        end
      _ ->
        changeset
    end
  end

  defp validate_colors(changeset) do
    changeset
    |> validate_block_type_colors()
    |> validate_energy_level_colors()
  end

  defp validate_block_type_colors(changeset) do
    case get_field(changeset, :block_type_colors) do
      nil -> changeset
      colors when is_map(colors) ->
        required_types = ~w(work meeting focus break planning review)
        if Enum.all?(Map.keys(colors), &(&1 in required_types)) && 
           Enum.all?(colors, fn {_, color} -> valid_hex_color?(color) end) do
          changeset
        else
          add_error(changeset, :block_type_colors, "must contain valid hex colors for block types")
        end
      _ -> add_error(changeset, :block_type_colors, "must be a map")
    end
  end

  defp validate_energy_level_colors(changeset) do
    case get_field(changeset, :energy_level_colors) do
      nil -> changeset
      colors when is_map(colors) ->
        required_levels = ~w(high medium low)
        if Enum.all?(Map.keys(colors), &(&1 in required_levels)) && 
           Enum.all?(colors, fn {_, color} -> valid_hex_color?(color) end) do
          changeset
        else
          add_error(changeset, :energy_level_colors, "must contain valid hex colors for energy levels")
        end
      _ -> add_error(changeset, :energy_level_colors, "must be a map")
    end
  end

  defp valid_hex_color?(color) when is_binary(color) do
    String.match?(color, ~r/^#[0-9A-Fa-f]{6}$/)
  end
  defp valid_hex_color?(_), do: false

  @doc """
  Gets all color palettes for a user, including the default TimeTracker palette
  """
  def get_user_palettes(preferences) do
    TimeTracker.Accounts.list_user_color_palettes(preferences.user_id)
  end

  @doc """
  Gets the appropriate color for a block type, considering user preferences
  """
  def get_block_type_color(preferences, block_type) do
    colors = Map.get(preferences, :block_type_colors) || %{}
    Map.get(colors, block_type)
  end

  @doc """
  Gets the appropriate color for an energy level, considering user preferences
  """
  def get_energy_level_color(preferences, energy_level) do
    colors = Map.get(preferences, :energy_level_colors) || %{}
    Map.get(colors, energy_level)
  end

  @doc """
  Updates a specific color setting in the preferences
  """
  def update_color(preferences, type, key, color) when type in [:block_type, :energy_level] do
    field = case type do
      :block_type -> :block_type_colors
      :energy_level -> :energy_level_colors
    end
    
    current_colors = Map.get(preferences, field) || %{}
    updated_colors = Map.put(current_colors, key, color)
    
    preferences
    |> Ecto.Changeset.change(%{field => updated_colors})
    |> Resolvinator.Repo.update()
  end

  @doc """
  Associates a color palette with the user preferences for a specific purpose.
  Valid purposes are: "block_types", "energy_levels", "breaks"
  """
  def assign_color_palette(preferences, palette_id, purpose) when purpose in ["block_types", "energy_levels", "breaks"] do
    Ecto.build_assoc(preferences, :color_palette_assignments, %{
      user_color_palette_id: palette_id,
      purpose: purpose
    })
  end

  @doc """
  Gets the color palette assigned for a specific purpose.
  Falls back to default_color_palette if no specific assignment exists.
  """
  def get_color_palette(preferences, purpose) when purpose in ["block_types", "energy_levels", "breaks"] do
    case Enum.find(preferences.color_palette_assignments, &(&1.purpose == purpose)) do
      nil -> preferences.default_color_palette
      assignment -> assignment.user_color_palette
    end
  end
end
