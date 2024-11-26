defmodule Resolvinator.Repo.Migrations.CreateUserHiddenDescriptions do
  use Ecto.Migration

  def change do
    create table(:user_hidden_descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # Note: user_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id, null: false
      add :description_id, references(:descriptions, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_hidden_descriptions, [:user_id, :description_id])
    create index(:user_hidden_descriptions, [:user_id])
    create index(:user_hidden_descriptions, [:description_id])
  end
end
