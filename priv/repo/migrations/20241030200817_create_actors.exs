defmodule Resolvinator.Repo.Migrations.CreateActors do
  use Ecto.Migration

  def change do
    create table(:actors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false
      add :description, :text
      add :role, :string, null: false
      add :influence_level, :string
      add :contact_info, :map, default: %{}
      add :status, :string, default: "active", null: false
      # Note: creator_id references resolvinator_acts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false
      add :project_id, references(:projects, type: :binary_id, on_delete: :restrict), null: false
      add :parent_actor_id, references(:actors, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:actors, [:creator_id])
    create index(:actors, [:project_id])
    create index(:actors, [:parent_actor_id])
    create unique_index(:actors, [:name, :project_id])
  end
end
