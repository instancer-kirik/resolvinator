defmodule Resolvinator.Repo.Migrations.CreateSolutions do
  use Ecto.Migration

  def change do
    create table(:solutions) do
      add :name, :string, null: false
      add :desc, :string, null: false
      add :author_id, references(:authors, on_delete: :nilify_all)
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      timestamps()
    end

    create index(:solutions, [:author_id])
  end
end
