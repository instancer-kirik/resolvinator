defmodule Resolvinator.Repo.Migrations.CreateProjectTokens do
  use Ecto.Migration

  def change do
    create table(:project_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token_id, :string, null: false
      add :token_uri, :string
      add :token_type, :string, null: false
      add :amount, :decimal
      add :staked_amount, :decimal
      add :stake_start_time, :utc_datetime
      add :stake_end_time, :utc_datetime
      add :metadata, :map
      
      add :project_id, references(:projects, type: :binary_id, on_delete: :delete_all), null: false
      add :owner_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:project_tokens, [:token_id])
    create index(:project_tokens, [:project_id])
    create index(:project_tokens, [:owner_id])
    create index(:project_tokens, [:token_type])
  end
end
