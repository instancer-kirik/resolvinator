defmodule Resolvinator.Repo.Migrations.AddConstraintsAndIndexes do
  use Ecto.Migration

  def change do
    # Risk Categories constraints
    alter table(:risk_categories) do
      add :status, :string
    end
    alter table(:risk_categories) do
      modify :status, :string, null: false, default: "active"
    end
    create constraint(:risk_categories, :status_must_be_valid,
      check: "status IN ('active', 'inactive', 'archived')")

    # Only create indexes that don't exist in original migration
    create_if_not_exists index(:risks, [:probability])
    create_if_not_exists index(:risks, [:impact])
    create_if_not_exists index(:risks, [:priority])
    create_if_not_exists index(:risks, [:status])

    # Mitigation strategy constraints
    alter table(:mitigations) do
      modify :strategy, :string, null: false
    end
    create constraint(:mitigations, :strategy_must_be_valid,
      check: "strategy IN ('avoid', 'transfer', 'mitigate', 'accept')")

    # Impact severity constraints
    alter table(:impacts) do
      modify :severity, :string, null: false
    end
    create constraint(:impacts, :severity_must_be_valid,
      check: "severity IN ('critical', 'high', 'medium', 'low', 'negligible')")

    # Soft deletion for risk-related tables
    alter table(:risks) do
      add :deleted_at, :utc_datetime
    end
    alter table(:risk_categories) do
      add :deleted_at, :utc_datetime
    end
    alter table(:impacts) do
      add :deleted_at, :utc_datetime
    end
    alter table(:mitigations) do
      add :deleted_at, :utc_datetime
    end
  end
end
