defmodule Resolvinator.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers) do
      add :name, :string, null: false
      add :description, :text
      add :status, :string, default: "active"
      add :rating, :integer
      add :contact_info, :map, default: %{}
      add :metadata, :map, default: %{}
      add :creator_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:suppliers, [:creator_id])
    create unique_index(:suppliers, [:name])
    create index(:suppliers, [:status])
    create index(:suppliers, [:rating])
  end
end
