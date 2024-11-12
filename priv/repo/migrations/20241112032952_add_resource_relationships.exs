defmodule Resolvinator.Repo.Migrations.AddResourceRelationships do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      add :resource_id, references(:resources, on_delete: :nilify_all)
    end

    create index(:rewards, [:resource_id])
  end
end