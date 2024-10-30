defmodule Resolvinator.Repo.Migrations.CreateMitigations do
  use Ecto.Migration

  def change do
    create table(:mitigations) do
      add :description, :text, null: false
      add :strategy, :string, null: false
      add :status, :string, default: "not_started", null: false
      add :effectiveness, :string
      add :cost, :decimal
      add :start_date, :date
      add :target_date, :date
      add :completion_date, :date
      add :notes, :text
      add :risk_id, references(:risks, on_delete: :delete_all), null: false
      add :creator_id, references(:users, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:mitigations, [:risk_id])
    create index(:mitigations, [:creator_id])
  end
end
