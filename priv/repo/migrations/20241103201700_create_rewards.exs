defmodule Resolvinator.Repo.Migrations.CreateRewards do
  use Ecto.Migration

  def change do
    create table(:rewards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :value, :integer, null: false
      add :status, :string, null: false, default: "pending"
      add :achievement_date, :utc_datetime
      add :expiry_date, :utc_datetime
      add :criteria, :map, default: %{}
      add :reward_type, :string, null: false
      add :tier, :string

      # Risk reward specific fields
      add :probability, :string
      add :timeline, :string
      add :dependencies, {:array, :binary_id}, default: []
      add :metadata, :map, default: %{}

      # Relationships
      add :project_id, references(:projects, on_delete: :restrict)
      add :achiever_id, references(:users, on_delete: :nilify_all)
      add :creator_id, references(:users, on_delete: :restrict), null: false
      add :risk_id, references(:risks, on_delete: :restrict)
      add :mitigation_id, references(:mitigations, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create index(:rewards, [:project_id])
    create index(:rewards, [:achiever_id])
    create index(:rewards, [:creator_id])
    create index(:rewards, [:risk_id])
    create index(:rewards, [:mitigation_id])
    create index(:rewards, [:reward_type])
    create index(:rewards, [:status])
    create index(:rewards, [:tier])
  end
end
