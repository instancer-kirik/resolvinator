defmodule Resolvinator.Repo.Migrations.AddMetadataToRisks do
  use Ecto.Migration

  def change do
    alter table(:risks) do
      add :metadata, :map, default: %{}
    end
  end
end