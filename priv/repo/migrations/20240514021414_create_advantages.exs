defmodule Resolvinator.Repo.Migrations.CreateAdvantages do
  use Ecto.Migration

  def change do
    create table(:advantages) do
      add :name, :string, null: false
      add :desc, :string, null: false
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      add :status, :string, default: "initial"
      add :rejection_reason, :string
      add :creator_id, references(:users, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    # Join table for users who "experience" the advantage
    create table(:user_advantages) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :advantage_id, references(:advantages, on_delete: :delete_all)
      
      timestamps(type: :utc_datetime)
    end

    create index(:advantages, [:creator_id])
    create index(:advantages, [:name])
    create unique_index(:user_advantages, [:user_id, :advantage_id])
  end
end
