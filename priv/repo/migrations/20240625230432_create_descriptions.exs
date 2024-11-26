defmodule Resolvinator.Repo.Migrations.CreateDescriptions do
  use Ecto.Migration

  def change do
    create table(:descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :descriptionable_type, :string, null: false
      add :descriptionable_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    # Composite index for polymorphic lookups
    create index(:descriptions, [:descriptionable_type, :descriptionable_id])
  end
end
