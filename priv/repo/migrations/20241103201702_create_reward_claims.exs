defmodule Resolvinator.Repo.Migrations.CreateRewardClaims do
  use Ecto.Migration

  def change do
    create table(:reward_claims, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, null: false, default: "pending"
      add :evidence, :map
      add :reviewed_at, :utc_datetime
      add :reward_id, references(:rewards, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :reviewed_by_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:reward_claims, [:reward_id])
    create index(:reward_claims, [:user_id])
    create index(:reward_claims, [:reviewed_by_id])
    create index(:reward_claims, [:status])
    create unique_index(:reward_claims, [:reward_id, :user_id])
  end
end
