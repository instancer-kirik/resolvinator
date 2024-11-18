defmodule Resolvinator.Repo.Migrations.CreateEtymologyTerms do
  use Ecto.Migration

  def change do
    create table(:etymology_terms, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :status, :string, default: "initial"
      add :visibility, :string, default: "public"
      add :metadata, :map, default: %{}
      add :tags, {:array, :string}, default: []
      add :priority, :integer

      # Etymology fields
      add :etymology, :text
      add :language_origin, :string
      add :first_known_use, :string
      add :pronunciation, :string
      add :part_of_speech, :string
      
      # Definition fields
      add :definitions, {:array, :string}
      add :usage_examples, {:array, :string}
      
      # Disambiguation fields
      add :disambiguations, {:array, :map}
      
      # Domain-specific fields
      add :domain_contexts, {:array, :string}
      add :domain_specific_definitions, :map

      # Common relationships
      add :creator_id, references(:users, type: :binary_id)
      add :project_id, references(:projects, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:etymology_terms, [:name])
    create index(:etymology_terms, [:language_origin])
    create index(:etymology_terms, [:part_of_speech])
    create index(:etymology_terms, [:domain_contexts], using: :gin)

    # Create join tables
    create table(:term_synonyms, primary_key: false) do
      add :term_id, references(:etymology_terms, type: :binary_id), null: false
      add :synonym_id, references(:etymology_terms, type: :binary_id), null: false
      timestamps(type: :utc_datetime)
    end

    create table(:term_antonyms, primary_key: false) do
      add :term_id, references(:etymology_terms, type: :binary_id), null: false
      add :antonym_id, references(:etymology_terms, type: :binary_id), null: false
      timestamps(type: :utc_datetime)
    end

    create table(:term_concept_relationships, primary_key: false) do
      add :term_id, references(:etymology_terms, type: :binary_id), null: false
      add :related_term_id, references(:etymology_terms, type: :binary_id), null: false
      add :relationship_type, :string
      timestamps(type: :utc_datetime)
    end

    # Add full-text search
    execute(
      """
      ALTER TABLE etymology_terms
      ADD COLUMN search_vector tsvector
      GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(etymology, '')), 'C') ||
        setweight(to_tsvector('english', array_to_string(definitions, ' ')), 'D')
      ) STORED
      """,
      "ALTER TABLE etymology_terms DROP COLUMN search_vector"
    )

    create index(:etymology_terms, [:search_vector], using: :gin)
  end
end 