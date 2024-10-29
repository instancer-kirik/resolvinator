defmodule Resolvinator.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :name, :string
      add :desc, :string
      add :upvotes, :integer
      add :downvotes, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:problems, [:user_id])
  end
end
