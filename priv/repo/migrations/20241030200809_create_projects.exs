defmodule Resolvinator.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :text
      add :status, :string, default: "planning", null: false
      add :risk_appetite, :string, null: false
      add :start_date, :date
      add :target_date, :date
      add :completion_date, :date
      add :settings, :map, default: %{}
      add :creator_id, references(:users, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:creator_id])
    create unique_index(:projects, [:name])
  end
end
