defmodule Resolvinator.Repo.Migrations.CreateRequirements do
  use Ecto.Migration

  def change do
    create table(:requirements, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :type, :string, null: false
      add :priority, :string, default: "medium"
      add :status, :string, default: "pending"
      add :validation_criteria, :text
      add :due_date, :date
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false
      add :project_id, references(:projects, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create index(:requirements, [:creator_id])
    create index(:requirements, [:project_id])
    create index(:requirements, [:status])
    create index(:requirements, [:priority])
  end
end
