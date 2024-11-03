defmodule Resolvinator.Repo.Migrations.CreateInventorySources do
  use Ecto.Migration

  def change do
    create table(:inventory_sources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :category, :string
      add :status, :string, default: "active"
      add :metadata, :map, default: %{}
      add :notes, :string

      # Source specific fields
      add :source_type, :string, null: false
      add :source_item_id, :string
      add :source_item_url, :string
      add :unit_price, :decimal
      add :currency, :string
      add :minimum_quantity, :integer
      add :maximum_quantity, :integer
      add :lead_time_days, :integer
      add :availability_status, :string
      add :last_checked_at, :utc_datetime
      add :auto_order_enabled, :boolean, default: false
      add :auto_order_threshold, :integer
      add :preferred_source, :boolean, default: false

      add :inventory_item_id, references(:inventory_items, on_delete: :restrict, type: :binary_id)
      add :supplier_id, references(:suppliers, on_delete: :restrict, type: :binary_id)
      add :creator_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :project_id, references(:projects, on_delete: :restrict, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:inventory_sources, [:inventory_item_id])
    create index(:inventory_sources, [:supplier_id])
    create index(:inventory_sources, [:creator_id])
    create index(:inventory_sources, [:project_id])
    create index(:inventory_sources, [:source_type])
    create index(:inventory_sources, [:status])
  end
end
