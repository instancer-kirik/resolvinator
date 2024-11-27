defmodule Resolvinator.Repo.Migrations.CreateAnswerRevisions do
  use Ecto.Migration

  def change do
    create table(:answer_revisions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :version, :integer
      add :change_summary, :string
      add :answer_id, references(:answers, type: :binary_id, on_delete: :delete_all)
      # Note: creator_id references resolvinator_accounts_fdw.users but we cannot use a foreign key
      # constraint because PostgreSQL does not support foreign keys to foreign tables.
      # Referential integrity will be handled at the application level.
      add :creator_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:answer_revisions, [:answer_id])
    create index(:answer_revisions, [:creator_id])
  end
end
