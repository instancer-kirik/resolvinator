defmodule Resolvinator.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :status, :string, default: "active"
      add :parent_id, references(:comments, on_delete: :nilify_all, type: :binary_id)
      add :commentable_id, :binary_id, null: false
      add :commentable_type, :string, null: false
      add :creator_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:parent_id])
    create index(:comments, [:commentable_id, :commentable_type])
    create index(:comments, [:creator_id])
    create index(:comments, [:status])
  end
end
