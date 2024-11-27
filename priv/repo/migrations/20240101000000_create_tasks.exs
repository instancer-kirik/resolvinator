defmodule Resolvinator.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :text
      add :status, :string, null: false, default: "pending"
      add :priority, :string, null: false, default: "medium"
      add :deadline, :date
      add :completed_at, :naive_datetime
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id, null: false
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :parent_task_id, references(:tasks, on_delete: :nilify_all)

      timestamps()
    end

    create index(:tasks, [:user_id])
    create index(:tasks, [:project_id])
    create index(:tasks, [:parent_task_id])
    create index(:tasks, [:deadline])
    create index(:tasks, [:status])
  end
end
