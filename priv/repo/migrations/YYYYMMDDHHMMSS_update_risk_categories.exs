defmodule Resolvinator.Repo.Migrations.UpdateRiskCategories do
  use Ecto.Migration

  def change do
    alter table(:risk_categories) do
      # Add new fields from ContentBehavior
      add :status, :string, default: "initial"
      add :visibility, :string, default: "public"
      add :metadata, :map, default: %{}
      add :tags, {:array, :string}, default: []
      add :priority, :integer
      
      # Add embedded schema fields
      add :voting, :map
      add :moderation, :map
      add :impacts, {:array, :map}
      
      # Add tracking fields if they don't exist
      add_if_not_exists :hidden, :boolean, default: false
      add_if_not_exists :hidden_at, :utc_datetime
      add_if_not_exists :hidden_by_id, references(:users, type: :binary_id)
      add_if_not_exists :deleted_at, :utc_datetime
    end

    # Add indexes
    create_if_not_exists index(:risk_categories, [:status])
    create_if_not_exists index(:risk_categories, [:hidden])
    create_if_not_exists index(:risk_categories, [:deleted_at])
    create_if_not_exists unique_index(:risk_categories, [:name, :project_id, :hidden])
  end

  defp add_if_not_exists(table, column, type, opts \\ []) do
    unless column_exists?(table, column) do
      add(table, column, type, opts)
    end
  end
end 