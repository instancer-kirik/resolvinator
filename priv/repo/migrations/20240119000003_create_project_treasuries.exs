defmodule Resolvinator.Repo.Migrations.CreateProjectTreasuries do
  use Ecto.Migration

  def change do
    create table(:project_treasuries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :total_balance, :decimal, null: false, default: 0
      add :rewards_pool, :decimal, null: false, default: 0
      add :dev_fund, :decimal, null: false, default: 0
      add :liquidity_fund, :decimal, null: false, default: 0
      add :emergency_reserve, :decimal, null: false, default: 0
      
      add :rewards_allocation, :decimal, null: false, default: 40
      add :dev_allocation, :decimal, null: false, default: 30
      add :liquidity_allocation, :decimal, null: false, default: 20
      add :reserve_allocation, :decimal, null: false, default: 10
      
      add :project_id, references(:projects, type: :binary_id)

      timestamps()
    end

    create index(:project_treasuries, [:project_id])

    create table(:treasury_allocations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :pool, :string, null: false
      add :amount, :decimal, null: false
      add :transaction_type, :string, null: false
      
      add :treasury_id, references(:project_treasuries, type: :binary_id)

      timestamps()
    end

    create index(:treasury_allocations, [:treasury_id])
    create index(:treasury_allocations, [:pool])

    create table(:treasury_transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :pool, :string, null: false
      add :amount, :decimal, null: false
      add :transaction_type, :string, null: false
      add :description, :text
      
      add :treasury_id, references(:project_treasuries, type: :binary_id)

      timestamps()
    end

    create index(:treasury_transactions, [:treasury_id])
    create index(:treasury_transactions, [:pool])
    create index(:treasury_transactions, [:transaction_type])
  end
end
