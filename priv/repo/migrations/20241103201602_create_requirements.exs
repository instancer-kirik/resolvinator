defmodule Resolvinator.Repo.Migrations.CreateRequirements do
  use Ecto.Migration

  def change do
    create table(:requirements) do
      add :name, :string, null: false
      add :description, :text
      add :type, :string, null: false
      add :priority, :string, default: "medium"
      add :status, :string, default: "pending"
      add :validation_criteria, :text
      add :due_date, :date
      add :creator_id, references(:users, on_delete: :restrict), null: false
      add :project_id, references(:projects, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create index(:requirements, [:creator_id])
    create index(:requirements, [:project_id])
    create index(:requirements, [:status])
    create index(:requirements, [:priority])
  end
end
