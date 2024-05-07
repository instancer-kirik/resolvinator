defmodule Resolvinator.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :name, :string, null: false
      add :desc, :string, null: false
      add :author_id, references(:authors, on_delete: :nilify_all)
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      timestamps()
    end

    create index(:problems, [:author_id])
  end
end
