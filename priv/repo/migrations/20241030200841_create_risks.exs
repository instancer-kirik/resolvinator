defmodule Resolvinator.Repo.Migrations.CreateRisks do
  use Ecto.Migration

  def change do
    create table(:risks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :probability, :string, null: false
      add :impact, :string, null: false
      add :priority, :string
      add :status, :string, default: "active", null: false
      add :mitigation_status, :string, default: "not_started", null: false
      add :detection_date, :date
      add :review_date, :date
      add :creator_id, references(:users, on_delete: :restrict), null: false
      add :project_id, references(:projects, on_delete: :restrict)
      add :risk_category_id, references(:risk_categories, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:risks, [:creator_id])
    create index(:risks, [:project_id])
    create index(:risks, [:risk_category_id])
  end
end
