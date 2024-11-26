defmodule Resolvinator.Repo.Migrations.AddTsvectorColumns do
  use Ecto.Migration

  def up do
    # Create GIN indexes for full-text search
    execute """
    CREATE EXTENSION IF NOT EXISTS unaccent;
    """

    alter table(:projects) do
      add :search_vector, :tsvector
    end

    # Create function to generate project search vector
    execute """
    CREATE OR REPLACE FUNCTION project_search_vector(name text, description text, status text)
    RETURNS tsvector AS $$
    BEGIN
      RETURN (
        setweight(to_tsvector('pg_catalog.english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('pg_catalog.english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('pg_catalog.english', coalesce(status, '')), 'C')
      );
    END
    $$ LANGUAGE plpgsql IMMUTABLE;
    """

    # Create trigger to automatically update search vector
    execute """
    CREATE TRIGGER projects_search_vector_update
      BEFORE INSERT OR UPDATE
      ON projects
      FOR EACH ROW
      EXECUTE FUNCTION
        tsvector_update_trigger(
          search_vector, 'pg_catalog.english',
          name, description, status
        );
    """

    # Create GIN index for the search vector
    create index(:projects, [:search_vector], using: :gin)

    # Update existing records
    execute """
    UPDATE projects
    SET search_vector = project_search_vector(name, description, status);
    """
  end

  def down do
    # Drop trigger
    execute "DROP TRIGGER IF EXISTS projects_search_vector_update ON projects;"

    # Drop function
    execute "DROP FUNCTION IF EXISTS project_search_vector;"

    # Drop index
    drop index(:projects, [:search_vector])

    # Drop column
    alter table(:projects) do
      remove :search_vector
    end
  end
end
