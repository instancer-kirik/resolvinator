defmodule Resolvinator.Repo.Migrations.CreateAdvantages do
  use Ecto.Migration

  def change do
    create table(:advantages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :desc, :string, null: false
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      add :status, :string, default: "initial"
      add :rejection_reason, :string
      add :creator_id, references(:users, type: :binary_id, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    # Join table for users who "experience" the advantage
    create table(:user_advantages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :advantage_id, references(:advantages, type: :binary_id, on_delete: :delete_all)
      
      timestamps(type: :utc_datetime)
    end

    create index(:advantages, [:creator_id])
    create index(:advantages, [:name])
    create unique_index(:user_advantages, [:user_id, :advantage_id])
  end
end
