defmodule Resolvinator.Repo.Migrations.CreateAdvantages do
  use Ecto.Migration

  def change do
    create table(:advantages) do
      add :name, :string
      add :desc, :string
      add :upvotes, :integer
      add :downvotes, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:advantages, [:user_id])
  end
end
