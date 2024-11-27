defmodule Resolvinator.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false
      add :description, :text
      add :quantity, :decimal
      add :unit, :string
      add :cost_per_unit, :decimal
      add :availability_status, :string, default: "available"
      add :metadata, :map, default: %{}
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false
      add :project_id, references(:projects, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create index(:resources, [:creator_id])
    create index(:resources, [:project_id])
    create index(:resources, [:type])
    create index(:resources, [:availability_status])
  end
end
