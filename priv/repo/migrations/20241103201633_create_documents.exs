defmodule Resolvinator.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :file_path, :string, null: false
      add :content_type, :string
      add :size, :integer
      add :status, :string, default: "pending"
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:documents, [:creator_id])
    create index(:documents, [:content_type])
    create index(:documents, [:status])
  end
end
