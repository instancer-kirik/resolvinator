defmodule Resolvinator.Repo.Migrations.AddColorsToUserSchedulingPreferences do
  use Ecto.Migration

  def change do
    alter table(:user_scheduling_preferences) do
      # Update break_preferences to include color
      modify :break_preferences, :map, default: %{
        "morning_break" => %{
          "preferred_time" => "10:30",
          "duration" => 15,
          "color" => "#90EE90"
        },
        "lunch_break" => %{
          "preferred_time" => "12:30",
          "duration" => 60,
          "color" => "#FFB6C1"
        },
        "afternoon_break" => %{
          "preferred_time" => "15:30",
          "duration" => 15,
          "color" => "#ADD8E6"
        }
      }

      # Update focus_time_preferences to include color
      modify :focus_time_preferences, :map, default: %{
        "preferred_times" => ["early_morning", "late_afternoon"],
        "min_duration" => 60,
        "max_interruptions" => 1,
        "color" => "#E6E6FA"
      }

      # Add new color-related fields
      add :block_type_colors, :map, default: %{
        "work" => "#98FB98",
        "meeting" => "#FFB6C1",
        "focus" => "#E6E6FA",
        "break" => "#87CEEB",
        "planning" => "#DDA0DD",
        "review" => "#F0E68C"
      }, null: false

      add :energy_level_colors, :map, default: %{
        "high" => "#90EE90",
        "medium" => "#F0E68C",
        "low" => "#ADD8E6"
      }, null: false

      add :color_palettes, {:array, :map}, default: [], null: false
    end
  end
end
