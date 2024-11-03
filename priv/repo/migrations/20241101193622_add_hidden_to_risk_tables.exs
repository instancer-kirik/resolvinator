defmodule Resolvinator.Repo.Migrations.AddHiddenToRiskTables do
  use Ecto.Migration

  def change do
    # Add hidden flag to relevant risk tables
    alter table(:risks) do
      add :hidden, :boolean, default: false
    end

    alter table(:impacts) do
      add :hidden, :boolean, default: false
    end

    alter table(:mitigations) do
      add :hidden, :boolean, default: false
    end

    alter table(:mitigation_tasks) do
      add :hidden, :boolean, default: false
    end
  end
end
