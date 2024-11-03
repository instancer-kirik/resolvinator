defmodule Resolvinator.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string, null: false
      add :description, :text
      add :file_path, :string, null: false
      add :content_type, :string
      add :size, :integer
      add :status, :string, default: "pending"
      add :creator_id, references(:users, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:documents, [:creator_id])
    create index(:documents, [:content_type])
    create index(:documents, [:status])
  end
end
