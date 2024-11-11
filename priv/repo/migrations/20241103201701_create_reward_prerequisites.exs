defmodule Resolvinator.Repo.Migrations.CreateRewardPrerequisites do
  use Ecto.Migration

  def change do
    create table(:reward_prerequisites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :required_count, :integer, null: false, default: 1
      add :reward_id, references(:rewards, on_delete: :delete_all), null: false
      add :required_reward_id, references(:rewards, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:reward_prerequisites, [:reward_id])
    create index(:reward_prerequisites, [:required_reward_id])
    create unique_index(:reward_prerequisites, [:reward_id, :required_reward_id])
  end
end
