defmodule Resolvinator.Repo.Migrations.CreateSupplierCatalogs do
  use Ecto.Migration

  def change do
    create table(:supplier_catalogs) do
      add :name, :string, null: false
      add :description, :text
      add :effective_date, :date, null: false
      add :expiry_date, :date
      add :status, :string, default: "active"
      add :items, {:array, :map}, default: []
      add :pricing_type, :string
      add :currency, :string
      add :metadata, :map, default: %{}
      
      add :supplier_id, references(:suppliers, on_delete: :delete_all), null: false
      add :creator_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:supplier_catalogs, [:supplier_id])
    create index(:supplier_catalogs, [:creator_id])
    create index(:supplier_catalogs, [:effective_date])
  end 