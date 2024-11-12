defmodule Resolvinator.Repo.Migrations.CreateTheorems do
  use Ecto.Migration
  import Resolvinator.Schema.ContentFields

  def change do
    # Create Theorems table with common content fields
    create table(:theorems, primary_key: false) do
      add_content_fields()
      
      # Theorem-specific fields
      add :formal_statement, :text
      add :proof_strategy, :string
      add :complexity_level, :string
      add :prerequisites, {:array, :string}, default: []
      add :field_of_study, :string
      add :notation_used, :map, default: %{}
    end

    # Add common indexes
    add_content_indexes(:theorems)

    # Create relationship tables
    create table(:theorem_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :theorem_id, references(:theorems, type: :binary_id, on_delete: :delete_all)
      add :related_theorem_id, references(:theorems, type: :binary_id, on_delete: :delete_all)
    end

    # Create relationship indexes
    create unique_index(:theorem_relationships, [:theorem_id, :related_theorem_id])
  end

  def down do
    drop table(:theorem_relationships)
    drop table(:theorems)
  end
end