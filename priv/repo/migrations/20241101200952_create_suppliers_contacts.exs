defmodule Resolvinator.Repo.Migrations.CreateSupplierContacts do
  use Ecto.Migration

  def change do
    create table(:supplier_contacts) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :role, :string, null: false
      add :primary, :boolean, default: false
      add :notes, :text
      add :status, :string, default: "active"
      add :metadata, :map, default: %{}
      
      add :supplier_id, references(:suppliers, on_delete: :delete_all), null: false
      add :creator_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:supplier_contacts, [:supplier_id])
    create index(:supplier_contacts, [:creator_id])
    create unique_index(:supplier_contacts, [:email, :supplier_id])
  end
end