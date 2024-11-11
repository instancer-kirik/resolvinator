defmodule Resolvinator.Repo.Migrations.CreateActors do
  use Ecto.Migration

  def change do
    create table(:actors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false
      add :description, :text
      add :role, :string, null: false
      add :influence_level, :string
      add :contact_info, :map, default: %{}
      add :status, :string, default: "active", null: false
      add :creator_id, references(:users, on_delete: :restrict), null: false
      add :project_id, references(:projects, on_delete: :restrict), null: false
      add :parent_actor_id, references(:actors, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:actors, [:creator_id])
    create index(:actors, [:project_id])
    create index(:actors, [:parent_actor_id])
    create unique_index(:actors, [:name, :project_id])
  end
end