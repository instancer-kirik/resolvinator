defmodule Resolvinator.Repo.Migrations.AddCommonContentFields do
  use Ecto.Migration

  def change do
    # List of all content tables
    content_tables = [:problems, :solutions, :advantages, :lessons]

    for table <- content_tables do
      alter table(table) do
        # Add new fields
        add :visibility, :string, default: "public"
        add :metadata, :map, default: %{}
        add :tags, {:array, :string}, default: []
        add :priority, :integer
        add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)
        add :voting, :map  # For embedded schema
        add :moderation, :map  # For embedded schema

        # Remove old fields that are now part of embeds
        remove :upvotes
        remove :downvotes
        remove :rejection_reason
      end

      # Add index for project relationship
      create index(table, [:project_id])
    end
  end

  def down do
    content_tables = [:problems, :solutions, :advantages, :lessons]

    for table <- content_tables do
      alter table(table) do
        # Remove new fields
        remove :visibility
        remove :metadata
        remove :tags
        remove :priority
        remove :project_id
        remove :voting
        remove :moderation

        # Restore original fields
        add :upvotes, :integer, default: 0
        add :downvotes, :integer, default: 0
        add :rejection_reason, :string
      end

      # Remove added index
      drop index(table, [:project_id])
    end
  end
end