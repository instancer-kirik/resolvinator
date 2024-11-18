defmodule Resolvinator.Repo.Migrations.CreateContributorRewards do
  use Ecto.Migration

  def change do
    create table(:contributor_rewards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :contribution_type, :string
      add :weight, :decimal
      add :tokens_earned, :decimal
      add :description, :text
      add :proof_of_work, :string
      add :status, :string, default: "pending"
      
      add :project_id, references(:projects, type: :binary_id)
      add :contributor_id, references(:users, type: :binary_id)
      add :approver_id, references(:users, type: :binary_id)

      timestamps()
    end

    create index(:contributor_rewards, [:project_id])
    create index(:contributor_rewards, [:contributor_id])
    create index(:contributor_rewards, [:status])
  end
end
