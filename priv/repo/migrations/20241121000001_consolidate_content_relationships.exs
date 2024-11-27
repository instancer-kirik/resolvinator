defmodule Resolvinator.Repo.Migrations.ConsolidateContentRelationships do
  use Ecto.Migration

  def change do
    create table(:content_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      
      # Source content
      add :source_id, :binary_id, null: false
      add :source_type, :string, null: false  # "problem", "solution", "lesson", "advantage"
      
      # Target content
      add :target_id, :binary_id, null: false
      add :target_type, :string, null: false  # "problem", "solution", "lesson", "advantage"
      
      # Relationship metadata
      add :relationship_type, :string  # e.g., "related", "depends_on", "solves", etc.
      add :metadata, :map, default: %{}
      add :bidirectional, :boolean, default: true
      
      timestamps(type: :utc_datetime)
    end

    # Indexes for efficient querying
    create index(:content_relationships, [:source_id, :source_type])
    create index(:content_relationships, [:target_id, :target_type])
    create unique_index(:content_relationships, [:source_id, :source_type, :target_id, :target_type, :relationship_type], 
                       name: :content_relationships_unique_index)

    # Drop the old relationship tables
    drop_if_exists table(:problem_relationships)
    drop_if_exists table(:problem_lesson_relationships)
    drop_if_exists table(:problem_advantage_relationships)
    drop_if_exists table(:problem_solution_relationships)
    drop_if_exists table(:lesson_relationships)
    drop_if_exists table(:advantage_relationships)
    drop_if_exists table(:solution_relationships)
  end
end
