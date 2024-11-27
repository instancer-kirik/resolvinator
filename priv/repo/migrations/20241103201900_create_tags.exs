defmodule Resolvinator.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :color, :string
      add :category, :string
      add :metadata, :map, default: %{}
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:tags, [:creator_id])
    create unique_index(:tags, [:name])

    create table(:taggings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tag_id, references(:tags, on_delete: :delete_all, type: :binary_id), null: false
      add :taggable_id, :binary_id, null: false
      add :taggable_type, :string, null: false
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:taggings, [:tag_id])
    create index(:taggings, [:taggable_id, :taggable_type])
    create index(:taggings, [:creator_id])
    create unique_index(:taggings, [:tag_id, :taggable_id, :taggable_type])
  end
end
