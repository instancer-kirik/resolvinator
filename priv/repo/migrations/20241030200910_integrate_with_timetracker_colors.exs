defmodule Resolvinator.Repo.Migrations.CreateColorPalettes do
  use Ecto.Migration

  def change do
    # Create our own color palettes table
    create table(:color_palettes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :colors, {:array, :map}, null: false
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id
      add :timetracker_id, :binary_id  # Optional reference to TimeTracker palette ID
      add :is_system_palette, :boolean, default: false, null: false
      
      timestamps(type: :utc_datetime)
    end

    create index(:color_palettes, [:creator_id])
    create index(:color_palettes, [:timetracker_id])

    # Create join table with shorter name to avoid index name truncation
    create table(:preference_palettes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :preference_id, references(:user_scheduling_preferences, type: :binary_id, on_delete: :delete_all), null: false
      add :palette_id, references(:color_palettes, type: :binary_id, on_delete: :delete_all), null: false
      add :purpose, :string, null: false  # e.g., "block_types", "energy_levels", "breaks"
      add :is_default, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:preference_palettes, [:preference_id])
    create index(:preference_palettes, [:palette_id])
    create unique_index(:preference_palettes, [:preference_id, :purpose], name: :preference_palettes_unique_purpose)
  end
end
