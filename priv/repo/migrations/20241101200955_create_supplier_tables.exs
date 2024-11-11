defmodule Resolvinator.Repo.Migrations.CreateSupplierTables do
  use Ecto.Migration

  def change do
    # Create suppliers table
    create table(:suppliers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :code, :string
      add :type, :string
      add :status, :string, default: "active"
      add :rating, :decimal
      add :payment_terms, :string
      add :lead_time_days, :integer
      add :minimum_order, :decimal
      add :website, :string
      add :integration_type, :string
      add :metadata, :map, default: %{}
      add :hidden, :boolean, default: false
      
      add :creator_id, references(:users, on_delete: :nilify_all)
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:suppliers, [:creator_id])
    create index(:suppliers, [:project_id])
    create index(:suppliers, [:status])
    create unique_index(:suppliers, [:code, :project_id])

    # Create supplier_contacts table
    create table(:supplier_contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string
      add :phone, :string
      add :role, :string
      add :notes, :text
      add :metadata, :map, default: %{}
      add :hidden, :boolean, default: false

      add :supplier_id, references(:suppliers, on_delete: :delete_all, type: :binary_id)
      add :creator_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:supplier_contacts, [:supplier_id])
    create index(:supplier_contacts, [:creator_id])
    create index(:supplier_contacts, [:email])
  end
end 