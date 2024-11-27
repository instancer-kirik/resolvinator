defmodule Resolvinator.Repo.Migrations.CreateUserSchedulingPreferences do
  use Ecto.Migration

  def change do
    create table(:user_scheduling_preferences) do
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id, null: false
      add :work_start_time, :time, null: false, default: "09:00:00"
      add :work_end_time, :time, null: false, default: "17:00:00"
      add :time_zone, :string, null: false
      add :work_days, {:array, :string}, null: false, default: ["monday", "tuesday", "wednesday", "thursday", "friday"]
      add :min_break_duration, :integer, null: false, default: 15
      add :preferred_break_intervals, :integer, null: false, default: 120
      add :max_daily_work_hours, :integer, null: false, default: 8
      add :max_daily_meetings, :integer, null: false, default: 4
      add :min_focus_block_duration, :integer, null: false, default: 60
      add :preferred_meeting_duration, :integer, null: false, default: 30

      # Energy and focus patterns
      add :high_energy_hours, {:array, :integer}, null: false, default: [9, 10, 11]
      add :medium_energy_hours, {:array, :integer}, null: false, default: [12, 13, 14, 15]
      add :low_energy_hours, {:array, :integer}, null: false, default: [16, 17]

      # Break and focus preferences as JSON
      add :break_preferences, :map, null: false
      add :focus_time_preferences, :map, null: false

      timestamps()
    end

    create unique_index(:user_scheduling_preferences, [:user_id])
  end
end
