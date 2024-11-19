defmodule Resolvinator.Repo.Migrations.AddCryptoFieldsToRewards do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      # Change value to decimal for precise crypto amounts
      remove :value
      add :value, :decimal, precision: 30, scale: 18
      add :currency, :string, default: "USD"

      # Crypto-specific fields
      add :wallet_address, :string
      add :transaction_hash, :string
      add :blockchain, :string
      add :token_contract, :string
      add :token_id, :string
      add :token_standard, :string
    end

    create index(:rewards, [:blockchain])
    create index(:rewards, [:token_contract])
    create index(:rewards, [:transaction_hash])
  end
end
