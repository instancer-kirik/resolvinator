defmodule Resolvinator.Repo.Migrations.CreateUserHiddenDescriptions do
  use Ecto.Migration

  def change do
    create table(:user_hidden_descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id
      add :description_id, references(:descriptions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:user_hidden_descriptions, [:user_id])
    create index(:user_hidden_descriptions, [:description_id])
  end
end
