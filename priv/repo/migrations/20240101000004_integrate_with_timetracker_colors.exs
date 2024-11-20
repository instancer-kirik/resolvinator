defmodule Resolvinator.Repo.Migrations.IntegrateWithTimeTrackerColors do
  use Ecto.Migration

  def change do
    # Remove our local color_palettes array and add reference to TimeTracker's palettes
    alter table(:user_scheduling_preferences) do
      remove :color_palettes
      add :default_color_palette_id, references(:user_color_palettes, on_delete: :nilify_all)
    end

    # Create join table for user preferences and color palettes
    create table(:user_scheduling_preferences_color_palettes) do
      add :user_scheduling_preference_id, references(:user_scheduling_preferences, on_delete: :delete_all), null: false
      add :user_color_palette_id, references(:user_color_palettes, on_delete: :delete_all), null: false
      add :purpose, :string, null: false  # e.g., "block_types", "energy_levels", "breaks"

      timestamps()
    end

    create index(:user_scheduling_preferences_color_palettes, [:user_scheduling_preference_id])
    create index(:user_scheduling_preferences_color_palettes, [:user_color_palette_id])
    create unique_index(:user_scheduling_preferences_color_palettes, [:user_scheduling_preference_id, :purpose])
  end
end
