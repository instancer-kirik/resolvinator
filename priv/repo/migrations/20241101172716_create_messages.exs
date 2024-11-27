defmodule Resolvinator.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :read, :boolean, default: false, null: false
      # Note: from_user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :from_user_id, :binary_id
      # Note: to_user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :to_user_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:from_user_id])
    create index(:messages, [:to_user_id])
  end
end
