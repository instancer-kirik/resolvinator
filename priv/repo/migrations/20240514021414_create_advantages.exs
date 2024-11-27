defmodule Resolvinator.Repo.Migrations.CreateAdvantages do
  use Ecto.Migration

  def change do
    create table(:advantages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string, null: false
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      add :status, :string, default: "initial"
      add :rejection_reason, :string
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    # Join table for users who "experience" the advantage
    create table(:user_advantages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      # Note: user_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :user_id, :binary_id
      add :advantage_id, references(:advantages, type: :binary_id, on_delete: :delete_all)
      
      timestamps(type: :utc_datetime)
    end

    create index(:advantages, [:creator_id])
    create index(:advantages, [:name])
    create unique_index(:user_advantages, [:user_id, :advantage_id])
  end
end
