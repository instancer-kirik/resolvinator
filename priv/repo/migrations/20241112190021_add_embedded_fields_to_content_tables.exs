defmodule Resolvinator.Repo.Migrations.AddEmbeddedFieldsToContentTables do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE problems ADD COLUMN IF NOT EXISTS impacts jsonb DEFAULT '[]'"
    execute "ALTER TABLE problems ADD COLUMN IF NOT EXISTS voting jsonb"
    execute "ALTER TABLE problems ADD COLUMN IF NOT EXISTS moderation jsonb"

    execute "ALTER TABLE solutions ADD COLUMN IF NOT EXISTS impacts jsonb DEFAULT '[]'"
    execute "ALTER TABLE solutions ADD COLUMN IF NOT EXISTS voting jsonb"
    execute "ALTER TABLE solutions ADD COLUMN IF NOT EXISTS moderation jsonb"

    execute "ALTER TABLE lessons ADD COLUMN IF NOT EXISTS impacts jsonb DEFAULT '[]'"
    execute "ALTER TABLE lessons ADD COLUMN IF NOT EXISTS voting jsonb"
    execute "ALTER TABLE lessons ADD COLUMN IF NOT EXISTS moderation jsonb"

    execute "ALTER TABLE advantages ADD COLUMN IF NOT EXISTS impacts jsonb DEFAULT '[]'"
    execute "ALTER TABLE advantages ADD COLUMN IF NOT EXISTS voting jsonb"
    execute "ALTER TABLE advantages ADD COLUMN IF NOT EXISTS moderation jsonb"
  end

  def down do
    alter table(:problems) do
      remove :impacts
      remove :voting
      remove :moderation
    end

    alter table(:solutions) do
      remove :impacts
      remove :voting
      remove :moderation
    end

    alter table(:lessons) do
      remove :impacts
      remove :voting
      remove :moderation
    end

    alter table(:advantages) do
      remove :impacts
      remove :voting
      remove :moderation
    end
  end
end