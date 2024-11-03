defmodule Resolvinator.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :content, :text
      add :type, :string, null: false
      add :status, :string, default: "unread"
      add :priority, :string, default: "normal"
      add :metadata, :map, default: %{}
      add :read_at, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :actor_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :project_id, references(:projects, on_delete: :nilify_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:actor_id])
    create index(:notifications, [:project_id])
    create index(:notifications, [:status])
    create index(:notifications, [:type])
    create index(:notifications, [:priority])
  end
end
