defmodule Resolvinator.Repo.Migrations.CreateResourceAllocations do
  use Ecto.Migration

  def change do
    create table(:resource_allocations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string, null: false
      add :amount, :decimal, null: false
      add :unit, :string
      add :start_date, :date
      add :end_date, :date
      add :status, :string
      add :notes, :text

      add :risk_id, references(:risks, on_delete: :restrict, type: :binary_id)
      add :mitigation_id, references(:mitigations, on_delete: :restrict, type: :binary_id)
      add :creator_id, references(:users, on_delete: :restrict, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:resource_allocations, [:risk_id])
    create index(:resource_allocations, [:mitigation_id])
    create index(:resource_allocations, [:creator_id])
    create index(:resource_allocations, [:type])
    create index(:resource_allocations, [:status])

    # Ensure allocation belongs to either risk or mitigation
    create constraint(:resource_allocations, :must_belong_to_risk_or_mitigation,
      check: "(risk_id IS NOT NULL AND mitigation_id IS NULL) OR (risk_id IS NULL AND mitigation_id IS NOT NULL)")
  end
end
