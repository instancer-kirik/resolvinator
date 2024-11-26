defmodule Resolvinator.Repo.Migrations.CreateTimeBlocks do
  use Ecto.Migration

  def change do
    create table(:time_blocks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_time, :naive_datetime, null: false
      add :end_time, :naive_datetime, null: false
      add :title, :string, null: false
      add :description, :text
      add :block_type, :string
      add :recurrence_rule, :string
      add :status, :string, null: false, default: "scheduled"
      # Note: user_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id, null: false
      add :task_id, references(:tasks, type: :binary_id, on_delete: :nilify_all)
      add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)
      add :calendar_event_id, :string

      # Scheduling preferences
      add :preferred_time_of_day, :string
      add :energy_level_required, :string
      add :focus_level_required, :string
      add :buffer_before, :integer, default: 0
      add :buffer_after, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:time_blocks, [:user_id])
    create index(:time_blocks, [:task_id])
    create index(:time_blocks, [:project_id])
    create index(:time_blocks, [:start_time])
    create index(:time_blocks, [:end_time])
    create index(:time_blocks, [:block_type])
    create index(:time_blocks, [:status])
  end
end
