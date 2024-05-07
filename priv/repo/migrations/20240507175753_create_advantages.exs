defmodule Resolvinator.Repo.Migrations.CreateAdvantages do
  use Ecto.Migration

  def change do
    create table(:advantages) do
      add :name, :string, null: false
      add :desc, :string, null: false
      add :author_id, references(:authors, on_delete: :nilify_all)
      add :upvotes, :integer, default: 0
      add :downvotes, :integer, default: 0
      timestamps()
    end

    create index(:advantages, [:author_id])
  end
end
