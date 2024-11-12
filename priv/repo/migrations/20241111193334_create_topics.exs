defmodule Resolvinator.Repo.Migrations.CreateTopics do
  use Ecto.Migration
  use Resolvinator.Schema.ContentFields

  def change do
    # Create Topics table
    create table(:topics, primary_key: false) do
      add_content_fields()
      
      # Topic-specific fields
      add :slug, :string
      add :parent_id, references(:topics, type: :binary_id, on_delete: :nilify_all)
      add :position, :integer
      add :is_featured, :boolean, default: false
      add :category, :string
      add :level, :string
      add :prerequisites, {:array, :string}, default: []
      add :learning_objectives, {:array, :string}, default: []
      add :content_count, :integer, default: 0
    end

    # Add common indexes
    add_content_indexes(:topics)

    # Add topic-specific indexes
    create index(:topics, [:slug])
    create index(:topics, [:parent_id])
    create index(:topics, [:category])
    create unique_index(:topics, [:slug, :project_id])

    # Create generic content-topic relationships table
    create table(:content_topic_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :topic_id, references(:topics, type: :binary_id, on_delete: :delete_all)
      add :content_type, :string  # e.g., "risk", "impact", "question", "theorem", etc.
      add :content_id, :binary_id # References any content type
      add :relationship_type, :string, default: "primary"
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    # Create indexes for the generic relationship table
    create index(:content_topic_relationships, [:topic_id])
    create index(:content_topic_relationships, [:content_type, :content_id])
    create unique_index(:content_topic_relationships, [:topic_id, :content_type, :content_id, :relationship_type])

    # Create topic-to-topic relationships table
    create table(:topic_relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :topic_id, references(:topics, type: :binary_id, on_delete: :delete_all)
      add :related_topic_id, references(:topics, type: :binary_id, on_delete: :delete_all)
      add :relationship_type, :string
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:topic_relationships, [:topic_id, :related_topic_id])
  end

  def down do
    drop table(:content_topic_relationships)
    drop table(:topic_relationships)
    drop table(:topics)
  end
end