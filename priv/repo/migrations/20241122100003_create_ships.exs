defmodule Resolvinator.Repo.Migrations.CreateShips do
  use Ecto.Migration

  def change do
    create table(:ships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :vessel_class, :string, null: false
      add :flag, :string
      add :crew_capacity, :integer
      add :tonnage, :integer
      
      add :hull_integrity, :float
      add :crew_morale, :float
      add :supplies, :float
      
      add :position, :map
      add :heading, :float
      add :speed, :float
      
      add :launched_at, :utc_datetime
      add :last_docked_at, :utc_datetime
      
      add :project_id, references(:projects, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:ships, [:project_id])
  end
end 