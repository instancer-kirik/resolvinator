defmodule Resolvinator.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :read, :boolean, default: false, null: false
      add :from_user_id, references(:users, on_delete: :nothing)
      add :to_user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:from_user_id])
    create index(:messages, [:to_user_id])
  end
end
