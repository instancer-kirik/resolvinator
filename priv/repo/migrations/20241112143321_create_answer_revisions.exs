defmodule Resolvinator.Repo.Migrations.CreateAnswerRevisions do
  use Ecto.Migration

  def change do
    create table(:answer_revisions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :version, :integer
      add :change_summary, :string
      add :answer_id, references(:answers, type: :binary_id, on_delete: :delete_all)
      add :creator_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:answer_revisions, [:answer_id])
    create index(:answer_revisions, [:creator_id])
  end
end