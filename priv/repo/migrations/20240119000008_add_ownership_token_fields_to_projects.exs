defmodule Resolvinator.Repo.Migrations.AddOwnershipTokenFieldsToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :ownership_token_hash, :string
      add :ownership_token_generated_at, :utc_datetime
    end

    create index(:projects, [:ownership_token_hash])
  end
end
