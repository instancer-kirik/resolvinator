defmodule Resolvinator.Repo.Migrations.CreateDescriptions do
  use Ecto.Migration

  def change do
    create table(:descriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :descriptionable_type, :string
      add :descriptionable_id, references(:gestures, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:descriptions, [:descriptionable_id])
    create index(:descriptions, [:descriptionable_type])
  end
end
